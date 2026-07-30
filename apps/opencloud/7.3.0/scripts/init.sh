#!/usr/bin/env bash
set -euo pipefail

# Create writable mount points before the first container start without
# sourcing untrusted dotenv values or recursively changing ownership of an
# arbitrary host path.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

env_get() {
    local key="$1"
    local value=""

    if [[ -f "$ENV_FILE" ]]; then
        value="$(grep -E "^${key}=" "$ENV_FILE" | tail -n 1 | cut -d '=' -f 2- || true)"
    fi
    if [[ ${#value} -ge 2 && "${value:0:1}" == '"' && "${value: -1}" == '"' ]]; then
        value="${value:1:${#value}-2}"
    elif [[ ${#value} -ge 2 && "${value:0:1}" == "'" && "${value: -1}" == "'" ]]; then
        value="${value:1:${#value}-2}"
    fi
    printf '%s\n' "$value"
}

prepare_dir() {
    local raw_path="$1"
    local absolute_path=""

    [[ -n "$raw_path" ]] || fail "OpenCloud data path must not be empty"
    case "$raw_path" in
        *$'\n'* | *$'\r'* | *'$'* | *'#'*) fail "Unsupported character in OpenCloud data path: $raw_path" ;;
    esac

    case "$raw_path" in
        /*) absolute_path="$(realpath -m -- "$raw_path")" ;;
        *)
            absolute_path="$(realpath -m -- "${ROOT_DIR}/${raw_path#./}")"
            case "$absolute_path" in
                "$ROOT_DIR"/*) ;;
                *) fail "Relative OpenCloud data path must stay inside the application directory: $raw_path" ;;
            esac
            ;;
    esac

    [[ "$absolute_path" != "/" ]] || fail "OpenCloud data path must not be the filesystem root"
    [[ ! -L "$absolute_path" ]] || fail "OpenCloud data path must not be a symbolic link: $absolute_path"
    if [[ -e "$absolute_path" && ! -d "$absolute_path" ]]; then
        fail "OpenCloud data path must be a directory: $absolute_path"
    fi

    mkdir -p -- "$absolute_path"
    chown "${OC_UID}:${OC_GID}" -- "$absolute_path"
}

OC_URL="$(env_get OC_URL)"
INITIAL_ADMIN_PASSWORD="$(env_get INITIAL_ADMIN_PASSWORD)"
PANEL_APP_BIND_IP="$(env_get PANEL_APP_BIND_IP)"
PROXY_TLS="$(env_get PROXY_TLS)"
INSECURE="$(env_get INSECURE)"
OC_CONTAINER_UID_GID="$(env_get OC_CONTAINER_UID_GID)"
OC_CONFIG_DIR="$(env_get OC_CONFIG_DIR)"
OC_DATA_DIR="$(env_get OC_DATA_DIR)"
OC_APPS_DIR="$(env_get OC_APPS_DIR)"
STORAGE_USERS_DRIVER="$(env_get STORAGE_USERS_DRIVER)"

[[ "$OC_URL" =~ ^https://[^[:space:]]+$ ]] || fail "OC_URL must be a non-empty HTTPS URL: $OC_URL"
[[ -n "$INITIAL_ADMIN_PASSWORD" ]] || fail "INITIAL_ADMIN_PASSWORD must be set before the first start"

case "${PANEL_APP_BIND_IP:-127.0.0.1}" in
    127.0.0.1 | 0.0.0.0) ;;
    *) fail "PANEL_APP_BIND_IP must be 127.0.0.1 or 0.0.0.0" ;;
esac

case "${PROXY_TLS:-false}" in
    true | false) ;;
    *) fail "PROXY_TLS must be true or false" ;;
esac

case "${INSECURE:-false}" in
    true | false) ;;
    *) fail "INSECURE must be true or false" ;;
esac

if [[ "${PROXY_TLS:-false}" == "false" && "${PANEL_APP_BIND_IP:-127.0.0.1}" == "0.0.0.0" ]]; then
    fail "Refusing to expose OpenCloud's plaintext reverse-proxy backend on 0.0.0.0; use 127.0.0.1 or enable PROXY_TLS"
fi

OC_CONTAINER_UID_GID="${OC_CONTAINER_UID_GID:-1000:1000}"
[[ "$OC_CONTAINER_UID_GID" =~ ^[0-9]+:[0-9]+$ ]] || fail "OC_CONTAINER_UID_GID must use numeric UID:GID format"
OC_UID="${OC_CONTAINER_UID_GID%%:*}"
OC_GID="${OC_CONTAINER_UID_GID##*:}"

case "${STORAGE_USERS_DRIVER:-decomposed}" in
    decomposed) ;;
    decomposeds3)
        for key in DECOMPOSEDS3_ENDPOINT DECOMPOSEDS3_ACCESS_KEY DECOMPOSEDS3_SECRET_KEY DECOMPOSEDS3_BUCKET; do
            [[ -n "$(env_get "$key")" ]] || fail "$key must be set when External S3 storage is selected"
        done
        ;;
    *) fail "STORAGE_USERS_DRIVER must be decomposed or decomposeds3" ;;
esac

prepare_dir "${OC_CONFIG_DIR:-./data/config}"
prepare_dir "${OC_DATA_DIR:-./data/storage}"
prepare_dir "${OC_APPS_DIR:-./data/apps}"
