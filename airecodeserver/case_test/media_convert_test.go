package case_test

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/tencentyun/cos-go-sdk-v5"
	"github.com/tencentyun/cos-go-sdk-v5/debug"
	"trpc.group/trpc-go/trpc-go/log"
)

// TestMediaConvert 录音文件转写
func (c *Suite) TestMediaConvert() {
	// 禁用证书验证
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	client := &http.Client{
		Transport: tr,
		Timeout:   10 * time.Second, // 设置请求超时
	}

	// 创建请求
	u := url.URL{
		Scheme: "https", Host: c.host, Path: "/v1/media/upload/credential",
	}

	reqObj := protocol.MediaUploadCredentialReq{
		MediaName:  GenUniqueID("fake_media_1"),
		FileFormat: "mp3",
		FileSize:   1,
		Duration:   1,
		RecordTime: time.Now().Format("2006-01-02 15:04:05"),
	}
	buf, _ := json.Marshal(reqObj)

	req, err := http.NewRequest("POST", u.String(), bytes.NewBuffer(buf))
	if err != nil {
		log.Fatalf("Failed to create request: %v", err)
		c.T().FailNow()
	}

	// 添加自定义头部
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "token bd61244b-c635-4c82-b92c-3b9e1a39aa18")

	// 发送请求
	resp, err := client.Do(req)
	if err != nil {
		log.Fatalf("Failed to make request: %v", err)
		c.T().FailNow()
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Fatalf("response error: %v", resp.Status)
		c.T().FailNow()
	}

	// log.Debugf("recv message: %+v", resp)

	// 读取响应体
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatalf("Failed to read response body: %v", err)
		c.T().FailNow()
	}

	rspObj := &protocol.MediaUploadCredentialRsp{}
	if err := json.Unmarshal(body, rspObj); err != nil {
		log.Fatalf("unmarshal err %+v", err)
		c.T().FailNow()
	}

	log.Infof("resp object: %+v", rspObj)

	// upload file
	ux, _ := url.Parse("https://" + "airecord-1251153477" + ".cos.ap-guangzhou.myqcloud.com")
	b := &cos.BaseURL{BucketURL: ux}
	cosCLi := cos.NewClient(b, &http.Client{
		Transport: &cos.AuthorizationTransport{
			// 使用临时密钥
			SecretID:     rspObj.Credential.TmpSecretId,
			SecretKey:    rspObj.Credential.TmpSecretKey,
			SessionToken: rspObj.Credential.SessionToken,
			Transport: &debug.DebugRequestTransport{
				RequestHeader:  true,
				ResponseHeader: true,
				ResponseBody:   true,
			},
		},
	})

	file, err := os.Open("./data/20240722-222133.mp3")
	if err != nil {
		c.T().Errorf("file open error: %+v", err)
		c.T().FailNow()
	}
	defer file.Close()

	s, err := file.Stat()
	if err != nil {
		c.T().Errorf("file state error: %+v", err)
		c.T().FailNow()
	}

	opt := &cos.ObjectPutOptions{
		ObjectPutHeaderOptions: &cos.ObjectPutHeaderOptions{
			ContentLength: s.Size(),
		},
	}

	_, err = cosCLi.Object.Put(context.Background(), rspObj.Credential.ObjectName, file, opt)
	if err != nil {
		c.T().Errorf("put error: %+v", err)
		c.T().FailNow()
	}

	// 转写
	reqBuf := fmt.Sprintf("{\"media_id\": %d,\"engine_type\":\"16k_zh\"}", rspObj.MediaId)

	urlConvert := url.URL{
		Scheme: "https", Host: c.host, Path: "/v1/media/convert",
	}
	reqConvert, err := http.NewRequest("POST", urlConvert.String(), bytes.NewBuffer([]byte(reqBuf)))
	if err != nil {
		log.Fatalf("Failed to create request: %v", err)
		c.T().FailNow()
	}

	// 添加自定义头部
	reqConvert.Header.Set("Content-Type", "application/json")
	reqConvert.Header.Set("Authorization", "token bd61244b-c635-4c82-b92c-3b9e1a39aa18")

	// 发送请求
	rspConvert, err := client.Do(reqConvert)
	if err != nil {
		log.Fatalf("Failed to make request: %v", err)
		c.T().FailNow()
	}
	defer rspConvert.Body.Close()

	rspConvertBody, err := io.ReadAll(rspConvert.Body)
	if err != nil {
		log.Fatalf("Failed to read response body: %v", err)
		c.T().FailNow()
	}

	rspConvertObj := &protocol.MediaConvertRsp{}
	if err := json.Unmarshal(rspConvertBody, rspConvertObj); err != nil {
		log.Fatalf("unmarshal err %+v", err)
		c.T().FailNow()
	}

	log.Infof("convert rsp: %+v", rspConvertObj)
}
