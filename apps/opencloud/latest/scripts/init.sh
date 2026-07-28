#!/usr/bin/env bash
set -euo pipefail

# OpenCloud runs as 1000:1000. Create writable mount points before the first
# container start without sourcing untrusted dotenv values or recursively
# changing ownership of an arbitrary host path.
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
    chown 1000:1000 -- "$absolute_path"
}

OC_CONFIG_DIR="$(env_get OC_CONFIG_DIR)"
OC_DATA_DIR="$(env_get OC_DATA_DIR)"

prepare_dir "${OC_CONFIG_DIR:-./data/config}"
prepare_dir "${OC_DATA_DIR:-./data/storage}"
prepare_dir "./data/apps"
