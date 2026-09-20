package entity

import "encoding/json"

// Sentence 句子/段落级别的识别结果
type Sentence struct {
  Index     int32  `json:"index"`      // 序号，从0开始递增
  StartTime uint32 `json:"start_time"` // 开始时间
  EndTime   uint32 `json:"end_time"`   // 结束时间
  Text      string `json:"text"`       // 文本结果
  SpeakId   int32  `json:"speak_id"`   // 说话人Id
}

// SentenceDetail 句子/段落级别的识别结果列表
type SentenceDetail struct {
  SentenceList []Sentence `json:"sentence_list"`
}

// Marshal 序列号为字符串
func (s *SentenceDetail) Marshal() string {
  buf, _ := json.Marshal(s)
  return string(buf)
}

// Unmarshal 字符串反序列化为SentenceDetail结构
func (s *SentenceDetail) Unmarshal(buf string) error {
  if len(buf) == 0 {
    return nil
  }

  return json.Unmarshal([]byte(buf), s)
}
