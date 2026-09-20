package asrv3

import (
	"context"
	"regexp"

	"github.com/smartox/ai_record_server/internal/application/ports/recognizer"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	tasr "github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/asr/v20190614"
	"github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/common"
	"github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/common/profile"
	"github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/common/regions"
)

func NewAudioRecognizer(cfg config.AsrCfg) recognizer.AudioRecognizer {
	return &AudioRecognizerImpl{
		cfg: cfg,
	}
}

type AudioRecognizerImpl struct {
	cfg config.AsrCfg
}

func (i *AudioRecognizerImpl) newClient() (*tasr.Client, error) {
	cpf := profile.NewClientProfile()

	credential := common.NewCredential(i.cfg.SecretId, i.cfg.SecretKey)

	return tasr.NewClient(credential, regions.Guangzhou, cpf)
}

// CreateRecTask 创建语音识别任务
func (i *AudioRecognizerImpl) CreateRecTask(ctx context.Context, request *recognizer.RecTaskRequest) (
	*recognizer.RecTask, error,
) {
	// 创建客户端
	client, err := i.newClient()
	if err != nil {
		return nil, err
	}

	// 构建请求消息
	req := tasr.NewCreateRecTaskRequest()
	req.EngineModelType = &request.EngineType
	req.ChannelNum = &request.ChannelNum
	req.ResTextFormat = &request.ResTextFormat
	req.SourceType = &request.SourceType
	req.Url = &request.Url
	req.SpeakerDiarization = &request.SpeakerDiarization
	req.SpeakerNumber = &request.SpeakerNumber

	// 发起请求
	rsp, err := client.CreateRecTaskWithContext(ctx, req)
	if err != nil {
		return nil, err
	}

	// 解析返回结果
	return &recognizer.RecTask{
		TaskId: *rsp.Response.Data.TaskId,
	}, nil
}

// DescribeTaskStatus  语音识别任务状态查询
func (i *AudioRecognizerImpl) DescribeTaskStatus(ctx context.Context, task *recognizer.RecTask) (
	*recognizer.RecTaskStatus, error,
) {
	// 创建客户端
	client, err := i.newClient()
	if err != nil {
		return nil, err
	}

	// 构建请求消息
	req := tasr.NewDescribeTaskStatusRequest()
	req.TaskId = &task.TaskId

	// 发起请求
	rsp, err := client.DescribeTaskStatusWithContext(ctx, req)
	if err != nil {
		return nil, err
	}

	// 解析返回结果
	status := recognizer.RecTaskStatus{
		TaskId:   task.TaskId,
		Status:   *rsp.Response.Data.Status,
		ErrorMsg: *rsp.Response.Data.ErrorMsg,
		Text:     *rsp.Response.Data.Result,
		Duration: int64(*rsp.Response.Data.AudioDuration * 1000),
	}

	// 结果处理
	re := regexp.MustCompile(`\[\d+:\d+\.\d+,\d+:\d+\.\d+,\d+\]`)
	// 替换匹配到的部分为空字符串
	status.Text = re.ReplaceAllString(status.Text, "")

	duration := uint32(0)
	for k, v := range rsp.Response.Data.ResultDetail {
		st := recognizer.Sentence{
			Index:     int32(k),
			StartTime: uint32(*v.StartMs),
			EndTime:   uint32(*v.EndMs),
			Text:      *v.FinalSentence,
			SpeakId:   int32(*v.SpeakerId),
		}
		status.SentenceList = append(status.SentenceList, st)

		if st.EndTime > duration {
			duration = st.EndTime
		}
	}

	if status.Status == recognizer.TaskStatusSuccess && status.Duration == 0 {
		status.Duration = int64(duration)
	}

	return &status, nil
}
