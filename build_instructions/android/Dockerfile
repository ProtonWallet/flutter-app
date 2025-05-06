FROM rust:1.79

ARG NDK_NUM=25.1.8937393
ARG NDK_NAME=android-ndk-r25b
ARG FLUTTER=flutter_linux_3.29.2-stable

ENV NDK_VERSION_NUM=${NDK_NUM}
ENV NDK_VERSION_NAME=${NDK_NAME}
ENV FLUTTER_VERSION=${FLUTTER}

RUN apt update 
RUN apt install -y curl
COPY install-deps.sh /install-deps.sh
RUN chmod +x /install-deps.sh
RUN /install-deps.sh

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
