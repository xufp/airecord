package cos

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"time"

	"github.com/smartox/ai_record_server/internal/application/ports/objectstorage"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/tencentyun/cos-go-sdk-v5"
	sts "github.com/tencentyun/qcloud-cos-sts-sdk/go"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewObjectStorage(cfg config.CosCfg) objectstorage.ObjectStorage {
	return &ObjectStorageImpl{
		cfg: cfg,
	}
}

type ObjectStorageImpl struct {
	cfg config.CosCfg
}

func (o *ObjectStorageImpl) GetCredential(ctx context.Context, objectName string) (*objectstorage.Credential, error) {
	c := sts.NewClient(
		o.cfg.SecretId,
		o.cfg.SecretKey,
		nil,
	)

	// 策略概述 https://cloud.tencent.com/document/product/436/18023
	opt := &sts.CredentialOptions{
		DurationSeconds: o.cfg.Expire,
		Region:          "ap-guangzhou",
		Policy: &sts.CredentialPolicy{
			Statement: []sts.CredentialPolicyStatement{
				{
					Action: []string{
						"name/cos:PostObject",
						"name/cos:PutObject",
						"name/cos:InitiateMultipartUpload",
						"name/cos:ListMultipartUploads",
						"name/cos:ListParts",
						"name/cos:UploadPart",
						"name/cos:CompleteMultipartUpload",
					},
					Effect: "allow",
					Resource: []string{
						// 这里改成允许的路径前缀，可以根据自己网站的用户登录态判断允许上传的具体路径，
						// 例子： a.jpg 或者 a/* 或者 * (使用通配符*存在重大安全风险, 请谨慎评估使用)
						// 存储桶的命名格式为 BucketName-APPID，此处填写的 bucket 必须为此格式
						"qcs::cos:" + o.cfg.Region + ":uid/" + o.cfg.AppId + ":" + o.cfg.Bucket + "/" + objectName,
					},
				},
			},
		},
	}

	res, err := c.GetCredential(opt)
	if err != nil {
		return nil, err
	}

	log.InfoContextf(ctx, "GetCredential rsp: %+v", res)

	credential := &objectstorage.Credential{
		TmpSecretID:  res.Credentials.TmpSecretID,
		TmpSecretKey: res.Credentials.TmpSecretKey,
		SessionToken: res.Credentials.SessionToken,
		StartTime:    res.StartTime,
		ExpiredTime:  res.ExpiredTime,
		ObjectName:   objectName,
	}

	return credential, nil
}

// GetObjectUrl 获取对象访问url
func (o *ObjectStorageImpl) GetObjectUrl(ctx context.Context, objectName string) (string, error) {
	u, _ := url.Parse(fmt.Sprintf("https://%s.%s", o.cfg.Bucket, o.cfg.Host))

	b := &cos.BaseURL{BucketURL: u}
	client := cos.NewClient(b, &http.Client{
		Transport: &cos.AuthorizationTransport{
			SecretID:  o.cfg.SecretId,
			SecretKey: o.cfg.SecretKey,
		},
	})

	opt := &cos.PresignedURLOptions{
		Query:  &url.Values{},
		Header: &http.Header{},
	}

	objectUrl, err := client.Object.GetPresignedURL(ctx, http.MethodGet, objectName, o.cfg.SecretId, o.cfg.SecretKey,
		time.Second*time.Duration(o.cfg.Expire), opt)
	if err != nil {
		return "", err
	}

	log.InfoContextf(ctx, "object url: %+v", objectUrl)
	return objectUrl.String(), nil
}

// PutObject 上传文件对象
func (o *ObjectStorageImpl) PutObject(ctx context.Context, fileName string, objectName string) error {
	u, _ := url.Parse(fmt.Sprintf("https://%s.%s", o.cfg.Bucket, o.cfg.Host))

	b := &cos.BaseURL{BucketURL: u}
	client := cos.NewClient(b, &http.Client{
		Transport: &cos.AuthorizationTransport{
			SecretID:  o.cfg.SecretId,
			SecretKey: o.cfg.SecretKey,
		},
	})

	file, err := os.Open(fileName)
	if err != nil {
		return err
	}
	defer func(file *os.File) {
		if err := file.Close(); err != nil {
			log.ErrorContextf(ctx, "file close failed. %+v", err)
		}
	}(file)

	s, err := file.Stat()
	if err != nil {
		log.ErrorContextf(ctx, "file state error: %+v", err)
		return err
	}

	opt := &cos.ObjectPutOptions{
		ObjectPutHeaderOptions: &cos.ObjectPutHeaderOptions{
			ContentLength: s.Size(),
		},
	}

	rsp, err := client.Object.Put(ctx, objectName, file, opt)
	if err != nil {
		return err
	}

	log.InfoContextf(ctx, "put object rsp: %+v", rsp)
	return nil
}
