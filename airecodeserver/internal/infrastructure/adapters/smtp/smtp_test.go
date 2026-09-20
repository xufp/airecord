package smtp

import (
	"testing"

	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
)

func TestVerifyCodeImpl_SendCode(t *testing.T) {
	type fields struct {
		cfg config.EmailCfg
	}
	type args struct {
		email string
		code  string
	}
	tests := []struct {
		name    string
		fields  fields
		args    args
		wantErr bool
	}{
		{
			name: "发送邮件",
			fields: fields{
				cfg: config.EmailCfg{
					SmtpHost: "smtp.example.com",
					SmtpPort: 25,
					UserName: "no_reply@example.com",
					Password: "YOUR_SMTP_PASSWORD",
				},
			},
			args: args{
				email: "test@example.com",
				code:  "567321",
			},
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			v := &VerifyCodeImpl{
				cfg:   tt.fields.cfg,
				scene: entity.VerifyCodeSceneLogin,
			}
			if err := v.SendCode(tt.args.email, tt.args.code); (err != nil) != tt.wantErr {
				t.Errorf("SendCode() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
