package interfaces

import (
	"context"
	"net/http"
	"sync"
	"sync/atomic"

	"github.com/gorilla/websocket"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/application/service/mediaservice"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

// 定义一个 WebSocket 升级器
var upGrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	// 允许所有来源连接
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// MediaSpeechHandler 实时语音识别处理
func (i *AiRecordServerServiceImpl) MediaSpeechHandler(w http.ResponseWriter, r *http.Request) {
	// websocket握手
	ctx := r.Context()
	// 请求消息解析
	var req protocol.MediaSpeechReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 启动速记前的业务处理
	media := mediaservice.NewMediaSpeech(i.depCtx.TransMgr, i.GetUserId(ctx))
	if err := media.MediaSpeech(ctx, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 升级HTTP连接到WebSocket连接
	conn, err := upGrader.Upgrade(w, r, nil)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	defer func() {
		if err := conn.Close(); err != nil {
			log.ErrorContextf(ctx, "MediaSpeechHandler connect close fail. err: %s", err.Error())
		}
		log.DebugContextf(ctx, "MediaSpeechHandler connect close succ. !!!")
	}()

	s := NewMediaSpeechService(conn, media)
	asrErr := s.Start(ctx)

	// media close.
	defer func() {
		if err := media.MediaClose(ctx, asrErr); err != nil {
			log.ErrorContextf(ctx, "Media file close fail. err %s", err.Error())
		}
		log.DebugContextf(ctx, "media file closed succ !!!")
	}()
}

func NewMediaSpeechService(conn *websocket.Conn, media *mediaservice.MediaSpeech) *MediaSpeechService {
	return &MediaSpeechService{
		conn:        conn,
		media:       media,
		mediaStream: make(chan protocol.MediaSpeechData),
		asrStream:   make(chan protocol.MediaSpeechRsp),
		connDone:    make(chan struct{}), // Initialize the done channel
		connState:   ConnStateReading,
		asrDone:     make(chan struct{}, 2),
	}
}

type MediaSpeechService struct {
	media       *mediaservice.MediaSpeech
	conn        *websocket.Conn
	mediaStream chan protocol.MediaSpeechData
	asrStream   chan protocol.MediaSpeechRsp
	wg          sync.WaitGroup
	connDone    chan struct{} // conn process done channel
	connState   int32         // 是否处于暂停
	asrDone     chan struct{} // asr process done channel
	asrErr      error
}

const (
	ConnStateReading = 1 // sending msg. or paused to resume
	ConnStatePaused  = 2 // send paused
	ConnStateEnd     = 3 // send eof
)

func (s *MediaSpeechService) Start(ctx context.Context) error {
	defer close(s.asrStream)
	defer close(s.asrDone)

	// 创建音频文件&音频识别
	if err := s.media.MediaCreate(ctx, s.mediaStream, s.asrStream); err != nil {
		// 发送错误消息
		if err := s.writeResponseMsg(int32(errs.Code(err)), err.Error()); err != nil {
			log.ErrorContextf(ctx, "MediaSpeechService conn write fail message error: %s", err.Error())
		}

		return err
	}

	// 返回创建成功消息
	if err := s.writeResponseMsg(0, "create success"); err != nil {
		log.ErrorContextf(ctx, "MediaSpeechService conn write start message error: %s", err.Error())
		return err
	}

	// start goroutine wait group
	s.wg.Add(2)

	// Goroutine for receiving messages from the WebSocket
	go s.processConnMessage(ctx)
	// Goroutine for processing ASR results
	go s.processAsrResult(ctx)

	// Wait for all goroutines to finish
	s.wg.Wait()

	return s.asrErr
}

func (s *MediaSpeechService) processConnMessage(ctx context.Context) {
	defer s.wg.Done()
	defer close(s.mediaStream)
	defer func() {
		log.InfoContextf(ctx, "conn stream exit!!! ")
	}()

	for {
		// 设置读取超时时间
		// _ = s.conn.SetReadDeadline(time.Now().Add(3 * time.Second))
		select {
		case <-s.connDone:
			log.InfoContextf(ctx, "conn stream done!!! ")
			return
		default:
			// 读取消息
			msgType, message, err := s.conn.ReadMessage()
			if err != nil {
				log.WarnContextf(ctx, "conn stream read message err: %s", err.Error())

				if atomic.LoadInt32(&s.connState) == ConnStateReading {
					s.mediaStream <- protocol.MediaSpeechData{DataType: websocket.TextMessage, Content: []byte("<EOF>")}
				} else {
					s.asrDone <- struct{}{}
				}
				return
			}

			// log.DebugContextf(ctx, "ws recv message type: %d, msg len: %v", msgType, len(message))

			switch msgType {
			case websocket.BinaryMessage:
				// 音频文件写入+识别
				if err := s.media.MediaWrite(ctx, message); err != nil {
					log.ErrorContextf(ctx, "receiveMessage write media file err: %s", err.Error())
				}

				s.mediaStream <- protocol.MediaSpeechData{DataType: msgType, Content: message}
			case websocket.TextMessage:
				log.DebugContextf(ctx, "ws recv message: %v, current conn state: %v", string(message),
					s.connState)
				if string(message) == "<EOF>" {
					if s.connState == ConnStatePaused {
						atomic.StoreInt32(&s.connState, ConnStateEnd)
						log.DebugContextf(ctx, "simulate pause end. input final message to asrStream")
						s.asrStream <- protocol.MediaSpeechRsp{
							Code:    0,
							Msg:     "paused end",
							MediaId: s.media.MediaId(),
							Result: protocol.SpeechResult{
								SliceType: protocol.SliceTypeStable,
								Index:     0,
								StartTime: 0,
								EndTime:   0,
								Text:      "",
							},
							Final: 1,
						}
					} else {
						atomic.StoreInt32(&s.connState, ConnStateEnd)
						s.mediaStream <- protocol.MediaSpeechData{DataType: msgType, Content: []byte("<EOF>")}
					}
					return
				} else if string(message) == "<PAUSE>" {
					if atomic.LoadInt32(&s.connState) == ConnStateReading {
						// 暂停
						atomic.StoreInt32(&s.connState, ConnStatePaused)

						// 通知下游结束并关闭当前识别流
						s.mediaStream <- protocol.MediaSpeechData{DataType: msgType, Content: []byte("<EOF>")}
						log.DebugContextf(ctx, "ws recv media stream pause. waiting resume...")
					}
				} else if string(message) == "<RESUME>" {
					if atomic.LoadInt32(&s.connState) == ConnStatePaused {
						if err := s.media.MediaResume(ctx, s.mediaStream, s.asrStream); err != nil {
							log.ErrorContextf(ctx, "MediaSpeechHandler resume error: %s", err.Error())
							s.mediaStream <- protocol.MediaSpeechData{DataType: msgType, Content: []byte("<EOF>")}
							s.asrErr = err

							if err := s.writeResponseMsg(int32(errs.Code(err)), err.Error()); err != nil {
								log.ErrorContextf(ctx, "MediaSpeechService Write <resume> fail message err: %s", err.Error())
							}
							return
						}

						atomic.StoreInt32(&s.connState, ConnStateReading)

						// 向前端返回一个恢复成功消息
						if err := s.writeResponseMsg(0, "<RESUME>"); err != nil {
							log.ErrorContextf(ctx, "MediaSpeechService Write <resume> err: %s", err.Error())
						}
					}
				}
			}
		}
	}
}

func (s *MediaSpeechService) processAsrResult(ctx context.Context) {
	defer s.wg.Done()
	defer close(s.connDone) // signal conn done
	// defer func() {
	// 	log.InfoContextf(ctx, "asrv2 stream exit!!! ")
	// 	// todo: 强制关闭，终止 ReadMessage 阻塞
	// 	_ = s.conn.Close() // 强制关闭连接，终止 ReadMessage 阻塞
	// }()

	for {
		select {
		case <-s.asrDone:
			log.InfoContextf(ctx, "asrv2 stream done!!!")
			return
		case msg, ok := <-s.asrStream:
			if !ok {
				log.ErrorContextf(ctx, "asrv2 stream closed!!!")
				return
			}

			if msg.Code == 0 {
				if msg.Final != 1 {
					// 内容修正
					msg = s.media.MediaConvertRspFix(msg)
					log.DebugContextf(ctx, "asrv2 stream recv message(fix): %+v", msg)

					// 稳定结果处理
					if msg.Result.SliceType == protocol.SliceTypeStable {
						if err := s.media.MediaConvert(ctx, msg); err != nil {
							log.WarnContextf(ctx, "processAsrResult MediaConvert handle error: %s", err.Error())
						}
					}

					// 回写
					if err := s.conn.WriteMessage(websocket.TextMessage, msg.Marshal()); err != nil {
						log.ErrorContextf(ctx, "processAsrResult Write Response error: %s", err.Error())
						// todo: 回写失败时，不退出。asrStream未收到结束消息，直接返回，可能引发panic
						// return
					}
				} else {
					log.DebugContextf(ctx, "asrv2 stream recv message: %+v", msg)

					// 非暂停时，结束消息需要回写,并退出goroutine
					if atomic.LoadInt32(&s.connState) != ConnStatePaused {
						if err := s.conn.WriteMessage(websocket.TextMessage, msg.Marshal()); err != nil {
							log.ErrorContextf(ctx, "processAsrResult Write Response error: %s", err.Error())
						}
						return
					}
				}
			} else {
				// todo: 可针对具体错误信息，进行独立处理逻辑
				// 记录错误信息
				s.asrErr = errs.Newf(msg.Code, msg.Msg)
				// 回写
				if err := s.conn.WriteMessage(websocket.TextMessage, msg.Marshal()); err != nil {
					log.ErrorContextf(ctx, "processAsrResult Write Response error: %s", err.Error())
				}

				return
			}
		}
	}
}

// writeResponseMsg 写回包消息
func (s *MediaSpeechService) writeResponseMsg(code int32, msg string) error {
	// 返回恢复确认消息
	rsp := protocol.MediaSpeechRsp{
		Code:    code,
		Msg:     msg,
		MediaId: s.media.MediaId(),
	}

	if err := s.conn.WriteMessage(websocket.TextMessage, rsp.Marshal()); err != nil {
		return err
	}
	return nil
}
