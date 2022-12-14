FROM nginx:1.23.3
ARG HOSTNAME
ARG IP

USER root
WORKDIR /root

# 証明書の生成と nginx の設定ファイルの上書きを行う
COPY gen_nginx_conf.sh ./
RUN ./gen_nginx_conf.sh ${HOSTNAME} ${IP}

