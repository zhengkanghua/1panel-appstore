#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

env_get() {
    local key="$1"
    local value=""

    value="$(grep -E "^${key}=" "$ENV_FILE" | tail -n 1 | cut -d '=' -f 2- || true)"
    if [[ ${#value} -ge 2 && "${value:0:1}" == '"' && "${value: -1}" == '"' ]]; then
        value="${value:1:${#value}-2}"
    elif [[ ${#value} -ge 2 && "${value:0:1}" == "'" && "${value: -1}" == "'" ]]; then
        value="${value:1:${#value}-2}"
    fi
    printf '%s\n' "$value"
}

[[ -f "$ENV_FILE" ]] || fail "OpenCloud environment file not found: $ENV_FILE"

if ! grep -q '^PANEL_APP_BIND_IP=' "$ENV_FILE"; then
    case "$(env_get PROXY_TLS)" in
        true) bind_ip="0.0.0.0" ;;
        false | "") bind_ip="127.0.0.1" ;;
        *) fail "Cannot migrate invalid PROXY_TLS value" ;;
    esac
    printf '\nPANEL_APP_BIND_IP="%s"\n' "$bind_ip" >> "$ENV_FILE"
fi

exec "${ROOT_DIR}/scripts/init.sh"
