package cos

import (
	"context"
	"net/http"
	"net/url"
	"os"
	"testing"

	"github.com/smartox/ai_record_server/internal/application/ports/objectstorage"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/tencentyun/cos-go-sdk-v5"
	"github.com/tencentyun/cos-go-sdk-v5/debug"
)

func TestObjectStorageCos_GetCredential(t *testing.T) {
	type fields struct {
		cfg config.CosCfg
	}
	type args struct {
		userId   int64
		fileName string
	}

	cfg := config.CosCfg{
		Host:      "cos.ap-guangzhou.myqcloud.com",
		AppId:     "YOUR_TENCENT_APP_ID",
		SecretId:  "YOUR_TENCENT_SECRET_ID",
		SecretKey: "YOUR_TENCENT_SECRET_KEY",
		Region:    "ap-guangzhou",
		Bucket:    "your-cos-bucket",
		Path:      "airecord/media",
		Expire:    7200,
	}

	tests := []struct {
		name    string
		cfg     config.CosCfg
		args    args
		want    *objectstorage.Credential
		wantErr bool
	}{
		{
			name:    "Test For GetCredential",
			cfg:     cfg,
			args:    args{12345, "airecord/media/9/media_name_00004.mp3"},
			want:    nil,
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			o := &ObjectStorageImpl{
				cfg: tt.cfg,
			}
			got, err := o.GetCredential(context.Background(), tt.args.fileName)
			if (err != nil) != tt.wantErr {
				t.Errorf("GetCredential() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if err != nil {
				t.Errorf("GetCredential() error = %v, wantErr %v", err, tt.wantErr)
				t.FailNow()
			}
			// if !reflect.DeepEqual(got, tt.want) {
			// 	t.Errorf("GetCredential() got = %v, want %v", got, tt.want)
			// }
			t.Logf("GetCredential: %+v", got)

			// upload file
			u, _ := url.Parse("https://" + cfg.Bucket + ".cos.ap-guangzhou.myqcloud.com")
			b := &cos.BaseURL{BucketURL: u}
			client := cos.NewClient(b, &http.Client{
				Transport: &cos.AuthorizationTransport{
					// 使用临时密钥
					SecretID:     got.TmpSecretID,
					SecretKey:    got.TmpSecretKey,
					SessionToken: got.SessionToken,
					Transport: &debug.DebugRequestTransport{
						RequestHeader:  true,
						ResponseHeader: true,
						ResponseBody:   true,
					},
				},
			})

			file, err := os.Open("../../../case_test/data/20240722-222133.mp3")
			if err != nil {
				t.Errorf("file open error: %+v", err)
				t.FailNow()
			}
			defer file.Close()

			s, err := file.Stat()
			if err != nil {
				t.Errorf("file state error: %+v", err)
				t.FailNow()
			}

			opt := &cos.ObjectPutOptions{
				ObjectPutHeaderOptions: &cos.ObjectPutHeaderOptions{
					ContentLength: s.Size(),
				},
			}

			_, err = client.Object.Put(context.Background(), got.ObjectName, file, opt)
			if err != nil {
				t.Errorf("put error: %+v", err)
				t.FailNow()
			}

			t.Logf("GetObjectUrl ---------------------------")
			purl, err := o.GetObjectUrl(context.Background(), got.ObjectName)
			if err != nil {
				t.Errorf("GetObjectUrl error: %+v", err)
				t.FailNow()
			}
			t.Logf("GetObjectUrl result: %s", purl)
		})
	}
}
