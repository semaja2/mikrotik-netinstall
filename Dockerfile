#Define our Netinstall Version
ARG NET_VERSION=7.5

# Download the netinstall files
FROM alpine:latest AS build
ARG NET_VERSION
WORKDIR /app
RUN wget -O /tmp/netinstall.tar.gz https://download.mikrotik.com/routeros/$NET_VERSION/netinstall-$NET_VERSION.tar.gz && \
  tar -xvf /tmp/netinstall.tar.gz


# Obtain qemu-user-static binaries
FROM debian:stable-slim AS qemu
WORKDIR /app
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends qemu-user-static && \
    ls -al /usr/bin && \
    cp $(which qemu-i386-static) .

# Combine everything
FROM alpine:latest
WORKDIR /app
RUN apk add --clean-protected --no-cache \
            bash \
            dumb-init && \
    rm -rf /var/cache/apk/*

## Copy out the qemu x86 binary
COPY --from=qemu /app/qemu-i386-static .

## Copy out the netinstall binary
COPY --from=build /app .

## Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

## Use micro init program to launch script
CMD ["dumb-init", "/entrypoint.sh"]