package utils

import (
	"net/mail"
	"regexp"

	"github.com/go-playground/validator/v10"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

// 创建一个验证器实例
var (
	validate *validator.Validate
)

func init() {
	validate = validator.New()
	// 注册自定义校验规则
	if err := validate.RegisterValidation("phone", validatePhoneNumber); err != nil {
		log.Errorf("RegisterValidation phone fail %+v", err)
	}
}

// validatePhoneNumber 自定义手机号码格式校验函数
func validatePhoneNumber(fl validator.FieldLevel) bool {
	phoneNumber := fl.Field().String()
	regex := `^1[3-9]\d{9}$`
	re := regexp.MustCompile(regex)
	return re.MatchString(phoneNumber)
}

// validateEmail 自定义邮箱验证函数
func validateEmail(fl validator.FieldLevel) bool {
	_, err := mail.ParseAddress(fl.Field().String())
	return err == nil
}

// ValidateStruct 验证结构体
func ValidateStruct[T any](input T) error {
	err := validate.Struct(input)
	if err != nil {
		for _, err := range err.(validator.ValidationErrors) {
			return errs.Newf(errorcode.ErrParamsInvalid, "params out of range %s: %s", err.Field(), err.Tag())
		}
	}
	return nil
}
