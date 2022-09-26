ARG NET_VERSION=7.5
FROM alpine:latest AS build
ARG NET_VERSION
WORKDIR /app
RUN wget -O /tmp/netinstall.tar.gz https://download.mikrotik.com/routeros/$NET_VERSION/netinstall-$NET_VERSION.tar.gz && \
  tar -xvf /tmp/netinstall.tar.gz
  
#FROM ubuntu:22.04
FROM debian:stable-slim
WORKDIR /app
COPY --from=build /app .
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends qemu-user tini && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    export QEMU_BIN=$(which qemu-i386) && \
    cp $QEMU_BIN /tmp/qemu-i386 && \
    rm -f /usr/bin/qemu-* && \
    rm -f /usr/local/bin/qemu-* && \
    cp /tmp/qemu-i386 $QEMU_BIN

COPY entrypoint.sh /entrypoint.sh

CMD ["tini", "/entrypoint.sh"]