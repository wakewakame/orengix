#!/bin/bash
set -eu

# orengix の起動
#
# 使い方: ./run.sh <hostname>
# 実行例: ./run.sh localhost

if [ $# != 1 ]; then
    echo "Usage: ./run.sh <hostname>"
    echo "Example: ./run.sh localhost"
    exit 1
fi

HOSTNAME=$1
SCRIPT_DIR="$(cd "$(dirname "$(readlink "$0" || echo "$0")")" && pwd)"

# 証明書発行
# (環境の違いによる openssl の差異をなくすために Docker で動かしている)
mkdir -p "${SCRIPT_DIR}/nginx/cert"
docker build \
    -t orengix_root_ca \
    --build-arg UID=$(id -u) \
    --build-arg GID=$(id -g) \
    ${SCRIPT_DIR}/root_ca/
docker run \
    --rm \
    --mount type=bind,source="${SCRIPT_DIR}/nginx/cert",target=/home/user/cert \
    orengix_root_ca \
    gen_cert.sh "${HOSTNAME}"

# nginx 起動
docker build \
    -t orengix \
    --build-arg CERT_CRT_PATH="${SCRIPT_DIR}/cert/cert.crt" \
    --build-arg CERT_CRT_PATH="${SCRIPT_DIR}/cert/cert.key" \
    ${SCRIPT_DIR}/nginx/
docker run \
    --rm \
    --name orengix \
    -p 80:80 \
    -p 443:443 \
    orengix

