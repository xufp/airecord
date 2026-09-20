package case_test

import (
	"fmt"
	"math/rand"
	"testing"
	"time"

	"github.com/stretchr/testify/suite"
	"trpc.group/trpc-go/trpc-go/log"
)

type Suite struct {
	suite.Suite

	host string
}

func TestRunSuite(t *testing.T) {
	suite.Run(t, new(Suite))
}

func (c *Suite) SetupSuite() {
	log.Infof("Begin SetupSuite() ...")
}

func (c *Suite) TearDownSuite() {
	log.Infof("Begin TearDownSuite() ...")
}

func (c *Suite) SetupTest() {
	log.Infof("Begin SetupTest() ...")

	c.host = "airecord.smarto.top:8081"
}

func (c *Suite) TearDownTest() {
	log.Infof("Begin TearDownTest() ...")
}

func GenUniqueID(prefix string) string {
	// 使用当前时间的Unix时间戳作为种子，确保每次运行时生成不同的随机数
	rand.Seed(time.Now().UnixNano())
	// 获取当前时间并格式化为字符串
	currentTime := time.Now().Format("20060102150405")
	// 生成一个6位数的随机数
	min := 100000
	max := 999999
	randomID := rand.Intn(max-min+1) + min

	return fmt.Sprintf("%s_%s_%d", prefix, currentTime, randomID)
}
