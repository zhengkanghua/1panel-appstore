#!/bin/bash

# OpenCloud 容器以 1000:1000 运行, 预创建数据目录并修正属主,
# 否则首次启动时 opencloud init 无法写入配置而反复重启
mkdir -p data/config data/storage data/apps
chown -R 1000:1000 data
