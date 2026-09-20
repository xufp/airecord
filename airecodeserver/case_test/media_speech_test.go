package case_test

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"trpc.group/trpc-go/trpc-go/log"
)

const (
	SliceSize = 6400
)

// TestMediaSpeech 实时语音识别测试
func (c *Suite) TestMediaSpeech() {
	queryParams := url.Values{}
	queryParams.Set("media_name", GenUniqueID("fake_media_2"))
	queryParams.Set("file_format", "mp3")
	queryParams.Set("engine_type", "16k_zh")

	u := url.URL{
		Scheme: "wss", Host: c.host, Path: "/v1/media/speech", RawQuery: queryParams.Encode(),
	}
	fmt.Println("Connecting to", u.String())

	dialer := websocket.DefaultDialer
	// 禁用证书验证（仅用于开发环境）
	dialer.TLSClientConfig = &tls.Config{InsecureSkipVerify: true}

	headers := http.Header{}
	headers.Set("Authorization", "token 815909a0-0d89-405c-8f97-91ee66d01712")

	conn, _, err := dialer.Dial(u.String(), headers)
	if err != nil {
		log.Fatal("Error connecting to WebSocket server:", err)
		c.T().FailNow()
	}

	defer func(conn *websocket.Conn) {
		log.Infof("connect closing ... ")

		err := conn.Close()
		if err != nil {
			log.Errorf("connect close fail.")
		}
	}(conn)

	audio, err := os.Open("./data/20240722-222133.mp3")
	if err != nil {
		log.Fatal("open file error: %v\n", err)
		c.T().FailNow()
	}

	defer func(audio *os.File) {
		err := audio.Close()
		if err != nil {
			log.Errorf("audio file close failed.")
		}
	}(audio)

	var wg sync.WaitGroup
	wg.Add(2)
	chanStop1 := make(chan string, 2)

	go func(chanStop chan string) {
		defer wg.Done()

		i := 0
		stop := false
		for !stop {
			i = i + 1
			select {
			case msg := <-chanStop1:
				if msg == "stop" {
					log.Infof("write goroutine stop!!!")
					stop = true
				}
			default:
				data := make([]byte, SliceSize)
				n, err := audio.Read(data)
				if err != nil {
					if err.Error() == "EOF" {
						log.Errorf("read file EOF.")
						stop = true
					}
					log.Errorf("read file error: %v\n", err)
					stop = true
				}
				if n <= 0 {
					stop = true
				}
				log.Infof("write msg len: %d", len(data))

				err = conn.WriteMessage(websocket.BinaryMessage, data[:n])
				if err != nil {
					stop = true
				}
			}

			// 模拟真实场景，200ms产生200ms数据
			time.Sleep(1 * time.Second)

			if i == 4 {
				log.Infof("write <PAUSE>")
				if err := conn.WriteMessage(websocket.TextMessage, []byte("<PAUSE>")); err != nil {
					log.Debugf("write EOF message error: %v\n", err)
				}

				time.Sleep(10 * time.Second)

				log.Infof("write <RESUME>")
				if err := conn.WriteMessage(websocket.TextMessage, []byte("<RESUME>")); err != nil {
					log.Debugf("write EOF message error: %v\n", err)
				}
				// 模拟真实场景，200ms产生200ms数据
				// time.Sleep(30 * time.Second)
			}
		}

		log.Infof("write <EOF>!!!")
		if err := conn.WriteMessage(websocket.TextMessage, []byte("<EOF>")); err != nil {
			log.Debugf("write EOF message error: %v\n", err)
		}
		// conn.Close()
	}(chanStop1)

	go func(chanStop chan string) {
		defer wg.Done()

		for {
			// 读取服务器的响应
			_, p, err := conn.ReadMessage()
			if err != nil {
				log.Errorf("read close message: %s", err)
				chanStop <- "stop"
				break
			}

			fmt.Println("Received message from server:", string(p))
			rsp := protocol.MediaSpeechRsp{}
			if err := json.Unmarshal(p, &rsp); err != nil || rsp.Final == 1 {
				log.Errorf("finnal close %+v", err)
				chanStop <- "stop"
				break
			}
		}
	}(chanStop1)

	// 等待读goroutine结束
	wg.Wait()
	// 确保在第一个 Goroutine 结束后关闭通道
	close(chanStop1)

	log.Infof("close all")
}
