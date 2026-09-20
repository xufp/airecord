#!/bin/bash

set -u

DIR="$(cd "$(dirname "$0")" ; pwd)"
cd $DIR/../bin

#获取上级目录
DIR_NAME="$(dirname "$PWD")"
#获取server名称
SERVER_NAME=`echo ${DIR_NAME##*/}`


Stop()
{
    all_pid=`ps aux | grep -w "$1" | grep "trpc_go.yaml" | grep -v grep |awk -F " " '{print $2}'`
    if [ "${all_pid}" = "" ]; then
        echo "shutdown: find no $1 process"
    else
        echo "shutdown: kill all $1 process"
        kill -9 ${all_pid}
    fi
}

Stop ${SERVER_NAME}