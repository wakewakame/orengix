FROM nginx:1.23.3
ARG UID
ARG GID

RUN groupadd -g $GID user && \
    useradd -m -s /bin/bash -u $UID -g $GID user
USER user

COPY ./gen_cert.sh /home/user/.local/bin/gen_cert.sh
ENV PATH $PATH:/home/user/.local/bin

WORKDIR /home/user/cert

