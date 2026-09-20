#!/bin/bash

DIR="$( cd "$(dirname "$0")" ; pwd)"
cd $DIR/bin

#获取上级目录
DIR_NAME="$(dirname "$PWD")"
#获取server名称
SERVER_NAME=`echo ${DIR_NAME##*/}`

REMOTE_DIR="/data/server/${SERVER_NAME}"

cp -rf $DIR/bin/${SERVER_NAME} ${REMOTE_DIR}/bin
cp -rf $DIR/script/restart.sh ${REMOTE_DIR}/bin
cp -rf $DIR/script/shutdown.sh ${REMOTE_DIR}/bin
cp -rf $DIR/script/reload.sh ${REMOTE_DIR}/bin
#cp -rf $DIR/conf/trpc_go.yaml ${REMOTE_DIR}/conf
cp -rf $DIR/conf/ai_record_server.yaml ${REMOTE_DIR}/conf
#cp -rf $DIR/conf/ssl/* ${REMOTE_DIR}/conf/ssh
cp -rf $DIR/web/dist/* ${REMOTE_DIR}/web/dist
