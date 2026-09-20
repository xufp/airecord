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

Start()
{
    echo "restart: starting $1"
    nohup ./$1 -conf=../conf/trpc_go.yaml &>>nohup.out &
    sleep 3
    counter=`ps -awef | grep -w "$1" | grep -v grep | grep -v "check.sh" | grep "trpc_go.yaml" | wc -l`
    if [ "$counter" -lt 1 ];then
      echo "restart: $1 failed to start"
      exit -1
    fi
    echo "restart: $1 started"
}

#Check_Account

sh shutdown.sh
ret_code=$?
if [ ${ret_code} -ne 0 ]; then
    echo "restart: failed to shutdown old process"
    exit $ret_code
fi

Start ${SERVER_NAME}
ret_code=$?
if [ ${ret_code} -ne 0 ]; then
    echo "${SERVER_NAME} start error"
    exit $ret_code
fi