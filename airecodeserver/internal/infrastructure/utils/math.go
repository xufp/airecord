package utils

import (
	"math"
	"math/rand"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/smartox/ai_record_server/internal/infrastructure/config"
)

const (
	BlockSize        = 1024 // 存储块 1MB = 1024KB
	BlockSecond      = 60   // 时间 1分钟 = 60秒
	BlockMillisecond = 1000 // 时间 1秒 = 1000毫秒
)

// OccupiedSize 存储空间占用，向上取整
func OccupiedSize(bytes int64) int64 {
	occupiedSize := int64(math.Ceil(float64(bytes) / float64(BlockSize))) // Round up to the nearest block size
	return occupiedSize
}

// OccupiedTime 服务时间占用，向上取整
func OccupiedTime(duration int64, block int64) int64 {
	occupiedDuration := int64(math.Ceil(float64(duration) / float64(block))) // Round up to the nearest block size
	return occupiedDuration
}

// TruncateString 字符截取
func TruncateString(s string, maxLength int) string {
	// 先去除空格和换行
	s = strings.ReplaceAll(s, "\n", "")
	s = strings.ReplaceAll(s, " ", "")

	if utf8.RuneCountInString(s) <= maxLength {
		return s
	}

	runes := []rune(s)
	return string(runes[:maxLength]) + "..."
}

// Contains 判断切片中是否包含指定的元素
func Contains(slice []string, item string) bool {
	for _, v := range slice {
		if v == item {
			return true
		}
	}
	return false
}

func GetObjectName(mediaUrl string) string {
	if strings.HasPrefix(mediaUrl, config.StorageModeCosPrefix) {
		return strings.TrimPrefix(mediaUrl, config.StorageModeCosPrefix)
	} else if strings.HasPrefix(mediaUrl, config.StorageModeFilePrefix) {
		return strings.TrimPrefix(mediaUrl, config.StorageModeFilePrefix)
	}
	return mediaUrl
}

func SplitToMap(str string) map[string]bool {
	// 创建一个空的 map
	m := make(map[string]bool)
	// 将字符串以逗号分隔并遍历
	for _, v := range strings.Split(str, ",") {
		m[v] = true
	}
	return m
}

// GetRandomString generates a random string of specified length
const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

// GetRandomString generates a secure random string of the specified length
func GetRandomString(length int) string {
	rand.Seed(time.Now().UnixNano())

	result := make([]byte, length)
	for i := range result {
		result[i] = charset[rand.Intn(len(charset))]
	}
	return string(result)
}

// ToBase62 将数字转换为62进制字符串
func ToBase62(num int64) string {
	// 定义62个字符：0-9、a-z、A-Z
	charset := "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

	// 如果数字为0，直接返回 "0"
	if num == 0 {
		return "0"
	}

	var result string
	// 不断对62取余并转换为字符
	for num > 0 {
		remainder := num % 62
		result = string(charset[remainder]) + result
		num = num / 62
	}

	return result
}

// CalcExpireTime 计算有效期截止时间（截止到当天23:59:59） startTime：起始时间 ，days：增加的自然日天数
func CalcExpireTime(startTime time.Time, days int) time.Time {
	if days == 0 {
		return startTime
	}

	// 增加指定天数
	targetDate := startTime.AddDate(0, 0, days)

	// 构造当日23:59:59时间
	return time.Date(
		targetDate.Year(),
		targetDate.Month(),
		targetDate.Day(),
		23, 59, 59, 0, // 固定时间部分
		targetDate.Location(), // 保持原时区
	)
}
