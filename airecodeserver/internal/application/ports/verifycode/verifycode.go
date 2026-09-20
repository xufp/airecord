package verifycode

type VerifyCode interface {
  SendCode(uniKey string, code string) error
}
