#!/bin/bash

# OpenCloud 容器以 1000:1000 运行, 预创建配置/数据目录并修正属主,
# 否则首次启动时 opencloud init 无法写入配置而反复重启

# 从 1Panel 按安装表单生成的 .env 中读取目录变量, 以支持用户自定义路径
# 不直接 source 整个 .env: 密码等字段可能含 $、反引号等会被 shell 展开的字符
env_get() {
    sed -n "s/^$1=//p" .env 2>/dev/null | tail -n 1 | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//"
}

OC_CONFIG_DIR="$(env_get OC_CONFIG_DIR)"
OC_DATA_DIR="$(env_get OC_DATA_DIR)"
OC_APPS_DIR="$(env_get OC_APPS_DIR)"

for dir in "${OC_CONFIG_DIR:-./data/config}" "${OC_DATA_DIR:-./data/storage}" "${OC_APPS_DIR:-./data/apps}"; do
    mkdir -p "$dir"
    chown -R 1000:1000 "$dir"
done
