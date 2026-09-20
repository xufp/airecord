package utils

import (
	"fmt"

	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

type ActivateCard struct {
	CardNo  string
	CardPwd string
}

const (
	ActivateCardMagic  = "C" // 激活码魔数
	ActivateCardMinLen = 18  // 最小长度
)

func NewActivateCard() *ActivateCard {
	return &ActivateCard{}
}

func (c *ActivateCard) Generate() *ActivateCard {
	c.CardNo = ToBase62(GetSnowflake().GenerateID())
	c.CardPwd = GetRandomString(6)
	return c
}

func (c *ActivateCard) Encode() string {
	if len(c.CardNo) == 0 || len(c.CardPwd) == 0 {
		return ""
	}

	return fmt.Sprintf("%s%s%s", ActivateCardMagic, c.CardPwd, c.CardNo)
}

func (c *ActivateCard) Decode(code string) error {
	if len(code) < ActivateCardMinLen || code[0] != ActivateCardMagic[0] {
		return errs.Newf(errorcode.ErrActivationCardInvalid, "invalid activation card code")
	}

	c.CardPwd = code[1:7]
	c.CardNo = code[7:]
	return nil
}
