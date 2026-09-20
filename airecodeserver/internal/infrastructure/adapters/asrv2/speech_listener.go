package asrv2

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/tencentcloud/tencentcloud-speech-sdk-go/asr"
	"trpc.group/trpc-go/trpc-go/log"
)

// SpeechListener implementation of SpeechListener
type SpeechListener struct {
	ctx       context.Context
	mediaId   int64
	asrStream chan protocol.MediaSpeechRsp
}

// OnRecognitionStart implementation of SpeechListener
func (listener *SpeechListener) OnRecognitionStart(response *asr.SpeechRecognitionResponse) {
	log.DebugContextf(listener.ctx, "%s|%s|OnRecognitionStart\n", time.Now().Format("2006-01-02 15:04:05"),
		response.VoiceID)
}

// OnSentenceBegin implementation of SpeechListener
func (listener *SpeechListener) OnSentenceBegin(response *asr.SpeechRecognitionResponse) {
	log.DebugContextf(listener.ctx, "%s|%s|OnSentenceBegin: %+v\n", time.Now().Format("2006-01-02 15:04:05"),
		response.VoiceID, response)
}

// OnRecognitionResultChange implementation of SpeechListener
func (listener *SpeechListener) OnRecognitionResultChange(response *asr.SpeechRecognitionResponse) {
	log.DebugContextf(listener.ctx, "%s|%s|OnRecognitionResultChange: %+v\n", time.Now().Format("2006-01-02 15:04:05"),
		response.VoiceID,
		response)

	rsp := protocol.MediaSpeechRsp{
		Code:    int32(response.Code),
		Msg:     response.Message,
		MediaId: listener.mediaId,
		Result: protocol.SpeechResult{
			SliceType: response.Result.SliceType,
			Index:     int32(response.Result.Index),
			StartTime: response.Result.StartTime,
			EndTime:   response.Result.EndTime,
			Text:      response.Result.VoiceTextStr,
		},
	}

	listener.asrStream <- rsp
}

// OnSentenceEnd implementation of SpeechListener
func (listener *SpeechListener) OnSentenceEnd(response *asr.SpeechRecognitionResponse) {
	log.DebugContextf(listener.ctx, "%s|%s|OnSentenceEnd: %+v\n", time.Now().Format("2006-01-02 15:04:05"),
		response.VoiceID, response)

	rsp := protocol.MediaSpeechRsp{
		Code:    int32(response.Code),
		Msg:     response.Message,
		MediaId: listener.mediaId,
		Result: protocol.SpeechResult{
			SliceType: response.Result.SliceType,
			Index:     int32(response.Result.Index),
			StartTime: response.Result.StartTime,
			EndTime:   response.Result.EndTime,
			Text:      response.Result.VoiceTextStr,
		},
	}

	listener.asrStream <- rsp
}

// OnRecognitionComplete implementation of SpeechListener
func (listener *SpeechListener) OnRecognitionComplete(response *asr.SpeechRecognitionResponse) {
	log.DebugContextf(listener.ctx, "%s|%s|OnRecognitionComplete: %+v\n", time.Now().Format("2006-01-02 15:04:05"),
		response.VoiceID, response)

	rsp := protocol.MediaSpeechRsp{
		Code:    int32(response.Code),
		Msg:     response.Message,
		MediaId: listener.mediaId,
		Final:   int32(response.Final),
	}

	listener.asrStream <- rsp
}

// OnFail implementation of SpeechListener
func (listener *SpeechListener) OnFail(response *asr.SpeechRecognitionResponse, err error) {
	log.DebugContextf(listener.ctx, "%s|%s|OnFail: %v, %+v\n", time.Now().Format("2006-01-02 15:04:05"), response.VoiceID,
		err, response)

	rsp := protocol.MediaSpeechRsp{
		Code:    int32(response.Code),
		Msg:     response.Message,
		MediaId: listener.mediaId,
		Final:   int32(response.Final),
	}

	listener.asrStream <- rsp
}
