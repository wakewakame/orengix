#!/bin/bash
set -eu

# これは Dockerfile から呼び出される想定のスクリプトです

HOSTNAME=$1
IP=$2

mkdir /etc/nginx/cert && cd /etc/nginx/cert

# 秘密鍵生成
openssl genrsa -out cert.key 4096

# CSR(証明書署名要求)の生成
openssl req -new -key cert.key -out cert.csr -subj="/CN=${HOSTNAME}"

# x509 v3 用の設定ファイル生成
echo "basicConstraints = critical, CA:FALSE" > x509v3.conf
echo "subjectAltName = IP:${IP},DNS:${HOSTNAME}" >> x509v3.conf
echo "extendedKeyUsage = serverAuth, clientAuth" >> x509v3.conf

# CRT(SSLサーバ証明書)の作成
# 有効期限は365日
openssl x509 -days 365 -req -signkey cert.key -in cert.csr -extfile x509v3.conf -out cert.crt

# 証明書の内容を確認してみる
#openssl x509 -in cert.crt -text

# /etc/nginx/conf.d/default.conf の上書き
echo \
"server {
    listen       80;
    listen  [::]:80;
    listen       443 ssl;
    listen  [::]:443 ssl;
    server_name  ${HOSTNAME};
    ssl_certificate     /etc/nginx/cert/cert.crt;
    ssl_certificate_key /etc/nginx/cert/cert.key;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
" > /etc/nginx/conf.d/default.conf

