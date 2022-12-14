#!/bin/bash
set -eu

# orengix の起動
#
# 使い方: ./run.sh <subject alt name> <ip address>
# 実行例: ./run.sh localhost 127.0.0.1

HOSTNAME=$1
IP=$2

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

docker build \
    -t orengix \
    --build-arg HOSTNAME=${HOSTNAME} \
    --build-arg IP=${IP} \
    ${SCRIPT_DIR}/

docker run \
    --rm \
    -i --log-driver=none -a stdout \
    orengix \
    cat /etc/nginx/cert/cert.crt \
    > ${SCRIPT_DIR}/cert.crt

docker run \
    --rm \
    --name orengix \
    -p 80:80 \
    -p 443:443 \
    orengix

