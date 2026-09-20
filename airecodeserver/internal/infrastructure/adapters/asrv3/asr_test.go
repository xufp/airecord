package asrv3

import (
	"context"
	"testing"
	"time"

	"github.com/smartox/ai_record_server/internal/application/ports/recognizer"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
)

func TestAudioRecognizerImpl_CreateRecTask(t *testing.T) {
	cfg := config.AsrCfg{
		AppId:     "YOUR_TENCENT_APP_ID",
		SecretId:  "YOUR_TENCENT_SECRET_ID",
		SecretKey: "YOUR_TENCENT_SECRET_KEY",
	}

	request := recognizer.NewRecTaskRequest()
	request.Url = "https://your-cos-bucket.cos.ap-guangzhou.myqcloud.com/airecord/media/12345/media_0001.mp3?YOUR_PRESIGNED_QUERY"

	tests := []struct {
		name    string
		cfg     config.AsrCfg
		request *recognizer.RecTaskRequest
		want    *recognizer.RecTask
		wantErr bool
	}{
		{
			name:    "语音识别",
			cfg:     cfg,
			request: request,
			want:    nil,
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			i := &AudioRecognizerImpl{
				cfg: tt.cfg,
			}
			got, err := i.CreateRecTask(context.Background(), tt.request)
			if (err != nil) != tt.wantErr {
				t.Errorf("CreateRecTask() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			// if !reflect.DeepEqual(got, tt.want) {
			// 	t.Errorf("CreateRecTask() got = %v, want %v", got, tt.want)
			// }

			// 查询结果
			for idx := 0; idx < 10; idx++ {
				status, err := i.DescribeTaskStatus(context.Background(), got)
				if err != nil {
					t.Errorf("DescribeTaskStatus fail, %+v", err)
					break
				}

				t.Logf("DescribeTaskStatus result: %+v", status)
				if status.Status == recognizer.TaskStatusSuccess {
					t.Logf("DescribeTaskStatus success")
					break
				} else if status.Status == recognizer.TaskStatusFailed {
					t.Errorf("DescribeTaskStatus failed. %+v", status.ErrorMsg)
					break
				}

				time.Sleep(time.Second * 2)
			}
		})
	}
}

func TestAudioRecognizerImpl_DescribeTaskStatus(t *testing.T) {
	cfg := config.AsrCfg{
		AppId:     "YOUR_TENCENT_APP_ID",
		SecretId:  "YOUR_TENCENT_SECRET_ID",
		SecretKey: "YOUR_TENCENT_SECRET_KEY",
	}

	tests := []struct {
		name    string
		cfg     config.AsrCfg
		request *recognizer.RecTask
		want    *recognizer.RecTask
		wantErr bool
	}{
		{
			name: "语音识别结果查询",
			cfg:  cfg,
			request: &recognizer.RecTask{
				TaskId: 11483210126,
			},
			want:    nil,
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			i := &AudioRecognizerImpl{
				cfg: tt.cfg,
			}

			status, err := i.DescribeTaskStatus(context.Background(), tt.request)
			if err != nil {
				t.Errorf("DescribeTaskStatus fail, %+v", err)
				return
			}

			t.Logf("DescribeTaskStatus result: %+v", status)
			if status.Status == recognizer.TaskStatusSuccess {
				t.Logf("DescribeTaskStatus success")
				return
			} else if status.Status == recognizer.TaskStatusFailed {
				t.Errorf("DescribeTaskStatus failed. %+v", status.ErrorMsg)
				return
			}
		})
	}
}
