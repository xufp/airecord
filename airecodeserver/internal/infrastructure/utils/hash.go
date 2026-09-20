package utils

import (
	"crypto/md5"
	"crypto/sha256"
	"encoding/hex"

	"github.com/google/uuid"
)

// GenerateMD5Hash 生成输入字符串的MD5哈希值
func GenerateMD5Hash(data string) string {
	hash := md5.New()
	hash.Write([]byte(data))
	hashBytes := hash.Sum(nil)
	return hex.EncodeToString(hashBytes)
}

// GenerateUUID 生成一个新的UUID
func GenerateUUID() string {
	id := uuid.New()
	return id.String()
}

// GenerateSha256 生成输入字符串的Sha256哈希值
func GenerateSha256(data string) string {
	hashBytes := sha256.Sum256([]byte(data))
	return hex.EncodeToString(hashBytes[:])
}
