package recognizer

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
)

//go:generate mockgen -source speech_recognizer.go -destination speech_recognizer.go -package recognizer

// SpeechRecognizer 音频识别接口
type SpeechRecognizer interface {
	// FlashRecognizer 录音文件极速识别
	FlashRecognizer(ctx context.Context, mediaRec *entity.MediaRec) error
	// SpeechRecognition 实时语音识别
	SpeechRecognition(
		ctx context.Context, mediaRec *entity.MediaRec, mediaStream chan protocol.MediaSpeechData,
		asrStream chan protocol.MediaSpeechRsp,
	) error
}
