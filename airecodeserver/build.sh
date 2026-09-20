#!/bin/bash

MODULE_NAME=ai_record_server

build() {
    # 配置编译环境的go
    if [ -d /opt/go-1.18.3 ]; then
        echo "use go-1.18.3 to build"
        export PATH=/opt/go-1.18.3/bin:$PATH
    else
        echo "use $(which go) to build"
    fi

    # 编译并打包
    go mod tidy
    mkdir -p ./bin && go build -o ./bin/"${MODULE_NAME}" ./cmd

    # 展示编译结果
    ls -lh ./bin/
}

clean() {
    echo "delete ./bin"
    if [ -d ./bin ]; then
        rm -rf ./bin
    fi
}

usage() {
  echo "usage:"
  echo "  $0 build: 编译"
  echo "  $0 clean: 删除编译产物"
  echo "  $0 all: 删除编译产物，重新编译"
  echo "default:"
  echo "  $0 build"
}

# 默认build指令
cmd="${1:-build}"

if [ -n "$cmd" ];then
    if [ "$cmd" = "build" ];then
        build
    elif [ "$cmd" = "clean" ];then
        clean
    elif [ "$cmd" = "all" ];then
        clean
        build
    else
        usage
    fi
else
  usage
fi
