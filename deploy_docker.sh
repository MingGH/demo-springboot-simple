#!/bin/bash

DEFAULT_PORT=5002
APP=demo-springboot-simple

PROG_NAME=$0
ACTION=$1
TAGNAME=$2
PROFILE=$3
PASS_PORT=$4

APP_PORT=${PASS_PORT:-$DEFAULT_PORT}
APP_NAME=${APP}-${PROFILE}
APP_HOME=/dockerData/runnable-run/${APP_NAME}
APP_OUT=${APP_HOME}/logs

# 阿里云仓库命名空间
APP_NAMESPACE=runnable-run
# 推送至阿里云仓库的地址
APP_REGISURL=
APP_RESP=${APP_REGISURL}/${APP_NAMESPACE}/${APP}
# 阿里云账号
APP_USERNAME=
# 阿里云配置个人容器镜像服务时，设置的密码
APP_PASSWORD=

mkdir -p ${APP_HOME}
mkdir -p ${APP_HOME}/logs

usage() {
    echo "Usage: $PROG_NAME {start|stop|restart|push}"
    exit 2
}

start_application() {
    echo "starting start_application"
    docker run \
     -e "SPRING_PROFILES_ACTIVE=${PROFILE}" \
     --log-opt max-size=1024m \
     --log-opt max-file=3 \
     --security-opt seccomp:unconfined \
     -dit \
     --name ${APP_NAME} \
     -p ${APP_PORT}:${DEFAULT_PORT} \
     --pid=host \
     -v ${APP_OUT}:/usr/local/${APP_NAME}/logs \
     ${APP_RESP}:${TAGNAME} \
    echo "ended start_application"
}

stop_application() {
    echo "ending stop_application"
    docker stop ${APP_NAME} && docker rm ${APP_NAME}
    echo "ended stop_application"
}

push_application() {
    echo "starting image push"
    docker login --username=${APP_USERNAME} --password=${APP_PASSWORD} ${APP_REGISURL}
    echo "docker tag ${APP_RESP}:${TAGNAME} ${APP_RESP}:${TAGNAME}"
    echo "docker push ${APP_RESP}:${TAGNAME}"

    docker tag ${APP_RESP}:${TAGNAME} ${APP_RESP}:${TAGNAME}
    docker push ${APP_RESP}:${TAGNAME}
    docker images|grep ${APP_RESP}|grep none|awk '{print $3 }'|xargs docker rmi
    echo "ended image push"
}

rmi_application() {
    docker rmi ${APP_RESP}:${TAGNAME}
}

start() {
    start_application
}
stop() {
    stop_application
}
push() {
    push_application
}
rmi() {
    rmi_application
}

case "$ACTION" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    restart)
        stop
        start
    ;;
    push)
        push
    ;;
    *)
        usage
    ;;
esac
