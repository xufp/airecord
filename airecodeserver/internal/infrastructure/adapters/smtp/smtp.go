package smtp

import (
	"crypto/tls"
	"fmt"
	"net/smtp"
	"os/exec"
	"strings"

	"github.com/smartox/ai_record_server/internal/application/ports/verifycode"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewVerifyCode(cfg config.EmailCfg, scene int32) verifycode.VerifyCode {
	api := VerifyCodeImpl{
		cfg:   cfg,
		scene: scene,
	}

	return &api
}

type VerifyCodeImpl struct {
	cfg   config.EmailCfg
	scene int32
}

func (v *VerifyCodeImpl) SendCode(email string, code string) error {
	if v.scene == entity.VerifyCodeSceneLogin {
		content := fmt.Sprintf("Dear AiRecorder,\n\nThank you for joining the AiRecord App.\n\n"+
			"Here is your AiRecord registration verification code:\n\n%s\n\nKindly copy the code and enter it on the registration page. "+
			"The code is exclusively for registration purposes and will expire in 15 minutes. Please don't share it with others.\n\n"+
			"If you encounter any issues during the registration process, please reach out to us at support@smarto.top, "+
			"and we will promptly assist you.\n\nCheers,\nThe AiRecord Team",
			code)

		if err := v.sendMailCmd(email, code+"|Your AiRecord Registration Code", content); err != nil {
			return err
		}
	} else if v.scene == entity.VerifyCodeSceneResetPassword {
		content := fmt.Sprintf("Dear AiRecorder,\n\n"+
			"Here is your AiRecord password resetting verification code:\n\n%s\n\nPlease note that this code is exclusively "+
			"for resetting your password and will expire in 15 minutes. To ensure the security of your account, "+
			"we kindly request that you refrain from sharing it with others.\n\n"+
			"If you face any difficulties while resetting your password, please don't hesitate to contact us at "+
			"support@smarto.top. We are here to provide you with prompt assistance!\n\nCheers,\nThe AiRecord Team",
			code)

		if err := v.sendMailCmd(email, code+"|Password Resetting Verification Code", content); err != nil {
			return err
		}
	} else {
		return errs.Newf(errorcode.ErrParamsInvalid, "not support verification code scene.")
	}

	return nil
}

func (v *VerifyCodeImpl) sendMailCmd(to string, subject string, body string) error {
	// 设置邮件的MIME头部信息
	header := make(map[string]string)
	header["From"] = fmt.Sprintf("%s <%s>", "AiRecord", v.cfg.UserName) // 自定义发件人名称
	header["To"] = to
	header["Subject"] = subject
	header["Content-Type"] = "text/plain; charset=UTF-8"
	header["Content-Transfer-Encoding"] = "7bit"

	// 构建邮件正文
	message := ""
	for k, v := range header {
		message += fmt.Sprintf("%s: %s\n", k, v)
	}
	message += "\n" + body

	// 创建TLS配置
	tlsConfig := &tls.Config{
		InsecureSkipVerify: true,
		ServerName:         v.cfg.SmtpHost,
	}

	// 建立TLS连接
	conn, err := tls.Dial("tcp", fmt.Sprintf("%s:%d", v.cfg.SmtpHost, v.cfg.SmtpPort), tlsConfig)
	if err != nil {
		fmt.Println("Error:", err)
		return err
	}
	defer func(conn *tls.Conn) {
		_ = conn.Close()
	}(conn)

	// 通过SMTP发送邮件
	client, err := smtp.NewClient(conn, fmt.Sprintf("%s:%d", v.cfg.SmtpHost, v.cfg.SmtpPort))
	if err != nil {
		fmt.Println("smtp new client error:", err)
		return err
	}

	// 身份验证
	if err = client.Auth(smtp.PlainAuth("", v.cfg.UserName, v.cfg.Password,
		fmt.Sprintf("%s:%d", v.cfg.SmtpHost, v.cfg.SmtpPort))); err != nil {
		fmt.Println("auth error:", err)
		return err
	}

	// 写入邮件内容
	if err = client.Mail(v.cfg.UserName); err != nil {
		fmt.Println("mail error:", err)
		return err
	}

	if err = client.Rcpt(to); err != nil {
		fmt.Println("rcpt error:", err)
		return err
	}

	w, err := client.Data()
	if err != nil {
		fmt.Println("create data error:", err)
		return err
	}

	if _, err := w.Write([]byte(message)); err != nil {
		fmt.Println("write data error:", err)
		return err
	}

	if err := w.Close(); err != nil {
		fmt.Println("write data handle close error:", err)
		return err
	}

	_ = client.Quit()

	log.Infof("mail send success!!!")
	return nil
}

func (v *VerifyCodeImpl) sendMailControl(to string, subject string, body string) error {
	fromName := "AiRecord"
	fromEmail := v.cfg.UserName
	from := fmt.Sprintf("%s <%s>", fromName, fromEmail) // 自定义发件人名称

	// 使用 `mail` 命令发送邮件
	cmd := exec.Command("mail", "-s", subject, "-a", fmt.Sprintf("From: %s", from), to)

	// 设置邮件正文
	cmd.Stdin = strings.NewReader(body)

	// 运行命令并获取输出
	err := cmd.Run()
	if err != nil {
		return fmt.Errorf("failed to send email: %v", err)
	}

	log.Infof("mail send success!!!")

	return nil
}
