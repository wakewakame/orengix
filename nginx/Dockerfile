FROM nginx:1.23.3
ARG CERT_CRT_PATH
ARG CERT_KEY_PATH

COPY ./cert/cert.crt /etc/nginx/cert/cert.crt
COPY ./cert/cert.key /etc/nginx/cert/cert.key
COPY ./default.conf /etc/nginx/conf.d/default.conf

