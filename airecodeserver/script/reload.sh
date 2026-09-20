#!/bin/bash

DIR="$( cd "$(dirname "$0")" ; pwd)"
cd $DIR/../bin

DESIGNATED_NAME="ubuntu"

if [ $# -eq 1 ]; then
    DESIGNATED_NAME=$1
    #echo "designated name:${DESIGNATED_NAME}"
fi

#获取上级目录
DIR_NAME="$(dirname "$PWD")"
#获取server名称
SERVER_NAME=`echo ${DIR_NAME##*/}`

CUR_USER_NAME=`whoami`

Check_Account()
{
    if [ "${CUR_USER_NAME}" = "root" ];then
        if [ "${DESIGNATED_NAME}" != "root" ];then
            echo "root change to ${DESIGNATED_NAME}"
            su ${DESIGNATED_NAME} -s ./restart.sh ${DESIGNATED_NAME}
            res=`echo $?`
            if [ ${res} -ne 0 ]; then
                exit -1;
            fi
            exit 0
        fi
    elif [ "${CUR_USER_NAME}" != "${DESIGNATED_NAME}" ]; then
        echo "please use ${DESIGNATED_NAME} account!"
        exit -1;
    fi
}

Reload()
{
  CUR_PID=`ps aux | grep -w "$1" | grep -v grep | grep -v "check.sh" | grep "trpc_go.yaml" | awk '{print $2}'`
  if [ "$CUR_PID" = "" ]; then
    echo "reload: $1 not running"
    ./restart.sh ${DESIGNATED_NAME}
    ret_code=$?
    if [ ${ret_code} -ne 0 ]; then
        echo "reload: failed to restart $1"
        exit $ret_code
    fi
    echo "reload: $1 restarted"
  else
    echo "reload: $1 is running, pid=$CUR_PID"

    # 发送软重启信号给老进程
    kill -USR2 $CUR_PID
    echo "reload: sent USR2 signal to $1, pid=$CUR_PID"

    # 等待老进程退出
    sleep 3
    counter=`ps -awef | grep -w "$1" | grep -v grep | grep -v "check.sh" | grep "trpc_go.yaml" | wc -l`
    if [ "$counter" -lt 1 ];then
      echo "reload: $1 failed to reload"
      exit -1
    fi
    echo "reload: $1 reloaded"
  fi
}

Check_Account

Reload ${SERVER_NAME}