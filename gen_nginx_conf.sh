#!/bin/bash
set -eu

# これは Dockerfile から呼び出される想定のスクリプトです

HOSTNAME=$1
IP=$2

mkdir /etc/nginx/cert && cd /etc/nginx/cert

# ルート認証局の秘密鍵を生成
openssl genrsa -out root_cert.key 4096

# ルート証明局の証明書署名要求を生成
openssl req -new -key root_cert.key -out root_cert.csr -subj="/CN=orengix"

# ルート認証局の x509 v3 用の設定ファイルを生成
echo "basicConstraints = critical, CA:TRUE" > root_x509v3.conf
echo "keyUsage = critical, keyCertSign, cRLSign" >> root_x509v3.conf

# ルート認証局の証明書を生成
# 有効期限は365日
openssl x509 -days 365 -req -signkey root_cert.key -in root_cert.csr -extfile root_x509v3.conf -out root_cert.crt

# エラーがないかチェックする
openssl verify -CAfile root_cert.crt root_cert.crt

# 上と同様の手順でエンドエンティティ証明書を生成
openssl genrsa -out cert.key 4096
openssl req -new -key cert.key -out cert.csr -subj="/CN=${HOSTNAME}"
echo "basicConstraints = critical, CA:FALSE" > x509v3.conf
echo "subjectAltName = IP:${IP},DNS:${HOSTNAME}" >> x509v3.conf
echo "extendedKeyUsage = serverAuth, clientAuth" >> x509v3.conf
openssl x509 -days 365 -req -CA root_cert.crt -CAkey root_cert.key -CAcreateserial -in cert.csr -extfile x509v3.conf -out cert.crt
openssl verify -CAfile root_cert.crt cert.crt

rm root_cert.csr root_x509v3.conf cert.csr x509v3.conf
chmod 0400 root_cert.key root_cert.crt cert.key cert.crt

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

