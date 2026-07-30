#!/bin/sh
set -eu

if [ "${PROXY_TLS}" = "false" ] && [ "${PANEL_APP_BIND_IP}" = "0.0.0.0" ]; then
    echo "Refusing to expose OpenCloud's plaintext reverse-proxy backend on 0.0.0.0" >&2
    exit 1
fi

if [ "${STORAGE_USERS_DRIVER}" = "decomposeds3" ]; then
    if [ -z "${STORAGE_USERS_DECOMPOSEDS3_ENDPOINT}" ] ||
       [ -z "${STORAGE_USERS_DECOMPOSEDS3_ACCESS_KEY}" ] ||
       [ -z "${STORAGE_USERS_DECOMPOSEDS3_SECRET_KEY}" ] ||
       [ -z "${STORAGE_USERS_DECOMPOSEDS3_BUCKET}" ]; then
        echo "S3 storage requires endpoint, access key, secret key and bucket" >&2
        exit 1
    fi
fi

opencloud init || true
exec opencloud server
