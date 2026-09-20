package recognizer

// RecTaskRequest 识别任务请求
type RecTaskRequest struct {
  EngineType         string `json:"engine_type"`         // 引擎类型 16k_zh：中文普通话通用引擎
  ChannelNum         uint64 `json:"channel_num"`         // 识别声道数 1：单声道, 2：双声道
  ResTextFormat      uint64 `json:"res_text_format"`     // 识别结果返回样式 0：基础识别结果, 1-3: 基础识别结果之上，增加词粒度的详细识别结果
  SourceType         uint64 `json:"source_type"`         // 音频数据来源  0：音频URL；1：音频数据（post body）
  VoiceFormat        string `json:"voice_format"`        // 音频格式。支持 wav、pcm、ogg-opus、speex、silk、mp3、m4a、aac、amr。 (SourceType=1时，需要)
  Url                string `json:"url"`                 // 音频URL的地址（需要公网环境浏览器可下载）
  SpeakerDiarization int64  `json:"speaker_diarization"` //  是否开启说话人分离 0：不开启； 1：开启
  SpeakerNumber      int64  `json:"speaker_number"`      // 说话人分离人数 0：自动分离（最多分离出20个人）； 1-10：指定人数分离；
}

// NewRecTaskRequest 创建识别人请求参数(默认参数)
func NewRecTaskRequest(engineType string) *RecTaskRequest {
  req := &RecTaskRequest{
    EngineType:         engineType, // 引擎类型 16k_zh：中文普通话通用引擎
    ChannelNum:         1,          // 识别声道数 1：单声道, 2：双声道
    ResTextFormat:      1,          // 识别结果返回样式 0：基础识别结果, 1-3: 基础识别结果之上，增加词粒度的详细识别结果
    SourceType:         0,          // 音频数据来源  0：音频URL；1：音频数据（post body）
    VoiceFormat:        "",         // 音频格式。支持 wav、pcm、ogg-opus、speex、silk、mp3、m4a、aac、amr。 (SourceType=1时，需要)
    Url:                "",         // <<需主动填充>> 音频URL的地址（需要公网环境浏览器可下载）
    SpeakerDiarization: 1,          //  是否开启说话人分离 0：不开启； 1：开启
    SpeakerNumber:      0,          // 说话人分离人数 0：自动分离（最多分离出20个人）； 1-10：指定人数分离；
  }

  // 16k_zh/16k_ms/16k_en/16k_id/16k_zh_large/16k_zh_dialect 不支持说话人分离
  if engineType != "16k_zh" && engineType != "16k_ms" && engineType != "16k_en" &&
      engineType != "16k_id" && engineType != "16k_zh_large" && engineType != "16k_zh_dialect" {
    req.SpeakerDiarization = 0
  }

  return req
}

// RecTask 识别任务
type RecTask struct {
  TaskId uint64 `json:"task_id"` // 任务ID
}

// RecTaskStatus 识别任务结果
type RecTaskStatus struct {
  TaskId       uint64     `json:"task_id"`       // 任务标识
  Status       int64      `json:"status"`        // 任务状态码，0：任务等待，1：任务执行中，2：任务成功，3：任务失败。
  ErrorMsg     string     `json:"error_msg"`     // 失败原因说明
  Duration     int64      `json:"duration"`      // 音频时长(毫秒)
  Text         string     `json:"text"`          // 识别结果(已识别完整文本)
  SentenceList []Sentence `json:"sentence_list"` // 识别结果详情(句子/段落级别的识别结果列表)
}

// Sentence 句子/段落级别的识别结果
type Sentence struct {
  Index     int32  `json:"index"`      // 序号，从0开始递增
  StartTime uint32 `json:"start_time"` // 开始时间
  EndTime   uint32 `json:"end_time"`   // 结束时间
  Text      string `json:"text"`       // 文本结果
  SpeakId   int32  `json:"speak_id"`   // ..
}

const (
  TaskStatusWaiting = 0 // 任务等待
  TaskStatusDoing   = 1 // 任务执行中
  TaskStatusSuccess = 2 // 任务成功
  TaskStatusFailed  = 3 // 任务失败
)
