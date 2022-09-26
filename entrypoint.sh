#!/bin/bash
set -e

NETINSTALL_ADDR="${NETINSTALL_ADDR:="192.168.88.1"}"
NETINSTALL_ARCH="${NETINSTALL_ARCH:="mipsbe"}"
NETINSTALL_NPK="${NETINSTALL_NPK:="routeros-${NETINSTALL_ARCH}-${LOAD_VERSION}.npk"}"

if [ ! -f /app/images/$NETINSTALL_NPK ]; then
    echo "Unable to find /app/images/$NETINSTALL_NPK"
    exit 1
fi

NETINSTALL_ARGS=""
if [ "${NETINSTALL_RESET}" ]; then
    NETINSTALL_ARGS="-r "
fi

if [[ $(uname -m) =~ (i[1-6]86|amd64) ]]; then
    exec /app/netinstall-cli $NETINSTALL_ARGS "-a" $NETINSTALL_ADDR /app/images/$NETINSTALL_NPK
else
    exec qemu-i386 /app/netinstall-cli $NETINSTALL_ARGS "-a" $NETINSTALL_ADDR /app/images/$NETINSTALL_NPK
fi