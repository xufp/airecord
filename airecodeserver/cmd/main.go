package main

import (
	"context"
	"flag"
	"fmt"

	"github.com/smartox/ai_record_server/internal/admin/router"
	"github.com/smartox/ai_record_server/internal/application/events"
	"github.com/smartox/ai_record_server/internal/domain/scheduler"
	"github.com/smartox/ai_record_server/internal/infrastructure/boot"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"github.com/smartox/ai_record_server/internal/interfaces"
	_ "trpc.group/trpc-go/trpc-filter/recovery"
	"trpc.group/trpc-go/trpc-go"
	thttp "trpc.group/trpc-go/trpc-go/http"
	"trpc.group/trpc-go/trpc-go/log"
	_ "trpc.group/trpc-go/trpc-selector-dsn"
)

func main() {
	// 设置时区为 UTC
	// loc, err := time.LoadLocation("Asia/Shanghai")
	// if err != nil {
	// 	panic(err)
	// }
	// time.Local = loc

	fmt.Println("Welcome to AI record")

	// 解析入参
	flag.StringVar(&trpc.ServerConfigPath, "conf", "../conf/trpc_go.yaml", "server config path")
	flag.Parse()

	// 框架初始化
	s := trpc.NewServer()

	// 配置初始化
	if err := config.InitServerConfig(trpc.GlobalConfig().Server.ConfPath); err != nil {
		log.Infof("init config fail. %s", trpc.GlobalConfig().Server.ConfPath)
		log.Fatal(err)
	}

	// 初始化Snowflake实例WorkerId
	if err := utils.SetWorkerId(config.GetServerConfig().Global.WorkerId); err != nil {
		log.Fatal(err)
	}

	// 依赖初始化
	depCtx, err := boot.NewDepContext()
	if err != nil {
		log.Infof("init dep context fail. %+v", err)
		log.Fatal(err)
	}

	// 启动定时任务调度器
	go func() {
		if err := scheduler.NewTaskScheduler().Run(context.Background(),
			events.NewAudioRecStatusTask(config.GetServerConfig().Crontab.AudioRecStatus, depCtx.TransMgr),
		); err != nil {
			log.Infof("run task scheduler fail. %+v", err)
			log.Fatal(err)
		}
	}()

	// 服务注册
	thttp.RegisterNoProtocolServiceMux(s.Service("http.ai_record_server.api"),
		interfaces.NewAiRecordServerServiceImpl(depCtx))
	if config.GetServerConfig().Admin.Enable {
		// 注册管理员服务
		thttp.RegisterNoProtocolServiceMux(s.Service("http.ai_record_server.admin"),
			router.NewAiRecordAdminImpl(depCtx))
	}

	// 运行程序
	if err := s.Serve(); err != nil {
		log.Fatal(err)
	}
}
