package utils

import (
	"fmt"
	"sync"
	"time"

	"trpc.group/trpc-go/trpc-go/log"
)

// 单例模式的雪花算法实例
var (
	once     sync.Once
	instance *Snowflake
	workerID int64 = 0 // 工作节点ID [0, 1024)
)

// SetWorkerId 设置workerID,
func SetWorkerId(id int64) error {
	if id < 0 || id > maxWorkerID {
		return fmt.Errorf("worker Id must be between 0 and %d", maxWorkerID)
	}

	workerID = id
	return nil
}

// GetSnowflake 获取全局唯一的雪花算法实例
func GetSnowflake() *Snowflake {
	once.Do(func() {
		instance, _ = NewSnowflake(workerID)
	})
	return instance
}

// Snowflake实现相关
const (
	// 位数常量
	timestampBits = 41 // 时间戳占用的位数
	workerIDBits  = 10 // 工作节点ID占用的位数
	sequenceBits  = 12 // 序列号占用的位数
	// 时间偏移量（开始时间）
	epoch = 1288834974657 // 2010-11-04 01:42:54
	// 全部掩码
	maxWorkerID  = -1 ^ (-1 << workerIDBits) // 最大的工作节点ID
	sequenceMask = -1 ^ (-1 << sequenceBits) // 最大序列号
)

// Snowflake 定义雪花算法的结构体
type Snowflake struct {
	sync.Mutex
	workerID      int64
	sequence      int64
	lastTimestamp int64
}

// NewSnowflake 创建雪花算法实例
func NewSnowflake(workerID int64) (*Snowflake, error) {
	if workerID < 0 || workerID > maxWorkerID {
		return nil, fmt.Errorf("worker Id must be between 0 and %d", maxWorkerID)
	}
	return &Snowflake{
		workerID: workerID,
	}, nil
}

// GenerateID 生成唯一 Id
func (s *Snowflake) GenerateID() int64 {
	s.Lock()         // 加锁
	defer s.Unlock() // 解锁

	timestamp := time.Now().UnixNano() / 1_000_000 // 当前时间戳（毫秒）

	if timestamp < s.lastTimestamp {
		log.Infof("clock moved backwards. Rejecting requests until %d", s.lastTimestamp)
		return 0
	}

	if s.lastTimestamp == timestamp {
		s.sequence = (s.sequence + 1) & sequenceMask
		if s.sequence == 0 {
			// 如果序列号用完，等待下一个毫秒
			for timestamp <= s.lastTimestamp {
				timestamp = time.Now().UnixNano() / 1_000_000
			}
		}
	} else {
		// 如果是新的一毫秒，重置序列号
		s.sequence = 0
	}

	s.lastTimestamp = timestamp

	// 组合 Id 并返回
	id := ((timestamp - epoch) << (workerIDBits + sequenceBits)) | (s.workerID << sequenceBits) | s.sequence
	return id
}
