#!/bin/bash
set -eu

# ルートCAの役割を担うスクリプト
# エンドエンティティ証明書を生成することができる
#
# 使い方: ./gen_cert.sh <hostname>
# 実行例: ./gen_cert.sh localhost
#
# 実行により生成されるファイル
# 1. ルート証明書が存在しない場合はルート証明書を生成
#    - root_ca.crt
#    - root_ca.key
#    - root_ca.srl
# 2. 引数に指定されたホスト名のエンドエンティティ証明書を生成
#    - cert.crt
#    - cert.key

HOSTNAME=$1

# ルート証明書が存在しない場合はルート証明書を生成
if [ ! -f root_ca.crt ] || [ ! -f root_ca.key ] || [ ! -f root_ca.srl ]; then
    rm -f root_ca.crt root_ca.key root_ca.srl

    # 秘密鍵を生成
    openssl ecparam -name prime256v1 -genkey -noout -out root_ca.key

    # 証明書署名要求を生成
    openssl req -new -sha256 -key root_ca.key -out root_ca.csr -subj="/CN=orengix"

    # x509 v3 用の設定ファイルを生成
    echo "basicConstraints = critical, CA:TRUE" > root_x509v3.conf
    echo "keyUsage = critical, keyCertSign, cRLSign" >> root_x509v3.conf

    # 証明書を生成
    # 有効期限は365日
    openssl x509 -days 365 -req -signkey root_ca.key -in root_ca.csr -extfile root_x509v3.conf -out root_ca.crt

    # エラーがないかチェックする
    openssl verify -CAfile root_ca.crt root_ca.crt

    rm root_ca.csr root_x509v3.conf
    chmod 0400 root_ca.key root_ca.crt
fi

# 上と同様の手順でエンドエンティティ証明書を生成
rm -f cert.crt cert.key
openssl ecparam -name prime256v1 -genkey -noout -out cert.key
openssl req -new -sha256 -key cert.key -out cert.csr -subj="/CN=${HOSTNAME}"
echo "basicConstraints = critical, CA:FALSE" > x509v3.conf
echo "subjectAltName = DNS:${HOSTNAME}" >> x509v3.conf
echo "extendedKeyUsage = serverAuth, clientAuth" >> x509v3.conf
openssl x509 -days 365 -req -CA root_ca.crt -CAkey root_ca.key -CAcreateserial -in cert.csr -extfile x509v3.conf -out cert.crt
openssl verify -CAfile root_ca.crt cert.crt
rm cert.csr x509v3.conf
chmod 0400 cert.key cert.crt

# 証明書の内容を確認してみる
openssl x509 -in cert.crt -text

