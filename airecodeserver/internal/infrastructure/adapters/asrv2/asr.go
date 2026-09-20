package asrv2

import (
	"context"
	"fmt"
	"io"
	"os"
	"time"

	"github.com/gorilla/websocket"
	"github.com/smartox/ai_record_server/internal/application/ports/recognizer"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/tencentcloud/tencentcloud-speech-sdk-go/asr"
	"github.com/tencentcloud/tencentcloud-speech-sdk-go/common"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewSpeechRecognizer(cfg config.AsrCfg) recognizer.SpeechRecognizer {
	api := SpeechRecognizerImpl{
		cfg: cfg,
	}
	return &api
}

type SpeechRecognizerImpl struct {
	cfg config.AsrCfg
}

func (i *SpeechRecognizerImpl) FlashRecognizer(ctx context.Context, mediaRec *entity.MediaRec) error {
	audio, err := os.Open(mediaRec.ObjectName)
	defer func(audio *os.File) {
		err := audio.Close()
		if err != nil {
			log.ErrorContextf(ctx, "audio file close fail %+v", err)
		}
	}(audio)

	if err != nil {
		fmt.Printf("open file error: %v\n", err)
		return err
	}

	credential := common.NewCredential(i.cfg.SecretId, i.cfg.SecretKey)
	rec := asr.NewFlashRecognizer(i.cfg.AppId, credential)
	data, err := io.ReadAll(audio)
	if err != nil {
		log.ErrorContextf(ctx, "%s|failed read data, error: %v\n", time.Now().Format("2006-01-02 15:04:05"), err)
		return err
	}

	req := new(asr.FlashRecognitionRequest)
	req.EngineType = mediaRec.EngineType
	req.VoiceFormat = mediaRec.Format
	req.SpeakerDiarization = 0
	req.FilterDirty = 0
	req.FilterModal = 0
	req.FilterPunc = 0
	req.ConvertNumMode = 1
	req.FirstChannelOnly = 1
	req.WordInfo = 0

	resp, err := rec.Recognize(req, data)
	if err != nil {
		log.ErrorContextf(ctx, "%s|failed do recognize, error: %v\n", time.Now().Format("2006-01-02 15:04:05"), err)
		return err
	}
	log.InfoContextf(ctx, "request_id: %s\n", resp.RequestId)
	mediaRec.RequestId = resp.RequestId

	if resp.Code != 0 {
		mediaRec.State = entity.MediaStateFailed
		mediaRec.Memo += "|" + resp.Message
	} else {
		mediaRec.State = entity.MediaStateSuccess
		mediaRec.Duration = resp.AudioDuration

		// 多声道，获取第一声道数据
		for _, channelResult := range resp.FlashResult {
			log.InfoContextf(ctx, "channel_id: %d, result: %s\n", channelResult.ChannelId, channelResult.Text)
			mediaRec.Text = channelResult.Text

			// SentenceDetail
			sentenceDetail := entity.SentenceDetail{}
			for k, v := range channelResult.SentenceList {
				sentence := entity.Sentence{
					Index:     int32(k),
					StartTime: v.StartTime,
					EndTime:   v.EndTime,
					Text:      v.Text,
					SpeakId:   v.SpeakerId,
				}
				sentenceDetail.SentenceList = append(sentenceDetail.SentenceList, sentence)
			}

			mediaRec.SentenceDetail = sentenceDetail.Marshal()
			// 多声道，仅获取第一声道数据
			break
		}
	}

	return nil
}

func GetVoiceFormat(format string) (int, error) {
	voiceFormat := 0
	switch format {
	case entity.MediaFileFormatPcm:
		voiceFormat = asr.AudioFormatPCM
	case entity.MediaFileFormatWav:
		voiceFormat = asr.AudioFormatWav
	case entity.MediaFileFormatMp3:
		voiceFormat = asr.AudioFormatMp3
	case entity.MediaFileFormatM4a:
		voiceFormat = asr.AudioFormatM4A
	case entity.MediaFileFormatOpus:
		voiceFormat = asr.AudioFormatOpus
	default:
		return 0, errs.Newf(errorcode.ErrParamsInvalid, "not support media format. %s", format)
	}

	return voiceFormat, nil
}

// SpeechRecognition 实时语音识别
func (i *SpeechRecognizerImpl) SpeechRecognition(
	ctx context.Context, mediaRec *entity.MediaRec, mediaStream chan protocol.MediaSpeechData,
	asrStream chan protocol.MediaSpeechRsp,
) error {
	listener := &SpeechListener{
		ctx:       ctx,
		mediaId:   mediaRec.MediaId,
		asrStream: asrStream,
	}

	credential := common.NewCredential(i.cfg.SecretId, i.cfg.SecretKey)
	log.DebugContextf(ctx, "credential %+v, media rec: %+v", credential, mediaRec)

	rec := asr.NewSpeechRecognizer(i.cfg.AppId, credential, mediaRec.EngineType, listener)

	format, err := GetVoiceFormat(mediaRec.Format)
	if err != nil {
		return err
	}
	rec.VoiceFormat = format

	log.DebugContextf(ctx, "recognizer %+v", rec)

	if err := rec.Start(); err != nil {
		log.ErrorContextf(ctx, "recognizer start failed, error: %v\n", err)
		return err
	}

	// 接收音频信息，转发识别
	go func() {
		for {
			data, ok := <-mediaStream
			if !ok {
				log.InfoContextf(ctx, "media stream closed!!!")
				break
			}

			if data.DataType == websocket.TextMessage && string(data.Content) == "<EOF>" {
				_ = rec.Stop()
			} else {
				err = rec.Write(data.Content)
				if err != nil {
					break
				}
			}
		}

		if err := rec.Stop(); err != nil {
			return
		}
	}()

	return nil
}
