package asrv2

import (
	"context"
	"testing"

	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
)

func TestTCloudApiImpl_FlashRecognizer(t *testing.T) {
	type args struct {
		asrCfg    config.AsrCfg
		ctx       context.Context
		mediaInfo *entity.MediaInfo
		mediaRec  *entity.MediaRec
	}

	asrCfg := config.AsrCfg{
		AppId:     "YOUR_TENCENT_APP_ID",
		SecretId:  "YOUR_TENCENT_SECRET_ID",
		SecretKey: "YOUR_TENCENT_SECRET_KEY",
	}
	mediaInfo := entity.MediaInfo{
		MediaId:    1,
		FileFormat: "mp3",
		MediaUrl:   "file:/Users/svenxyang/Downloads/20240722-222133.mp3",
	}
	mediaRec := entity.MediaRec{
		MediaId:    1,
		EngineType: "16k_zh",
	}

	testArgs := args{
		asrCfg:    asrCfg,
		ctx:       context.Background(),
		mediaInfo: &mediaInfo,
		mediaRec:  &mediaRec,
	}

	tests := []struct {
		name    string
		args    args
		wantErr bool
	}{
		{
			name:    "极速识别",
			args:    testArgs,
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			i := &SpeechRecognizerImpl{
				cfg: tt.args.asrCfg,
			}
			if err := i.FlashRecognizer(tt.args.ctx, tt.args.mediaRec); (err != nil) != tt.wantErr {
				t.Errorf("FlashRecognizer() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
