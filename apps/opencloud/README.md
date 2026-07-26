# OpenCloud

## 应用简介

OpenCloud 是一个开源的文件管理、共享和协作平台，简洁且自主可控。它是 ownCloud Infinite Scale (oCIS) 的活跃分支，专注于现代化架构和性能优化。

英文说明：OpenCloud is the open source platform for file management, sharing and collaboration. Simple and sovereign.

## 部署说明

- 本应用使用 Docker Compose 在 1Panel 中部署，参考 [opencloud-compose](https://github.com/opencloud-eu/opencloud-compose) 官方仓库。
- 应用分类：网站。
- 支持架构：amd64, arm64。
- 使用 `opencloudeu/opencloud-rolling` 镜像（滚动更新版本），当前版本 `7.3.0`。
- 安装后可通过 Web 浏览器访问 OpenCloud 界面。

## 架构说明

OpenCloud 采用单一容器架构，内部集成了以下服务：

| 服务 | 端口 | 说明 |
|------|------|------|
| OpenCloud Server | 9200 | 主服务，包含 Web UI, WebDAV, WOPI |
| Metrics (可选) | 9205 | Prometheus 监控指标 |

所有流量通过内部的 `PROXY_HTTP_ADDR=0.0.0.0:9200` 监听，无需额外反向代理即可运行。

## 首次运行

1. 部署完成后，通过 `http://服务器IP:端口` 访问 OpenCloud
2. 默认管理员用户名：`admin`
3. 管理员密码：在安装时设置的 `INITIAL_ADMIN_PASSWORD`
4. > **重要**：管理员密码只在首次启动时生效，后续修改需要在 OpenCloud 用户设置界面或通过 CLI 操作

## 端口

| 变量 | 说明 | 默认值 | 必填 |
| --- | --- | --- | --- |
| PANEL_APP_PORT_HTTP | HTTP端口（映射到容器内 9200） | 8080 | 是 |

## 数据持久化

| 变量 | 说明 | 默认值 | 必填 |
| --- | --- | --- | --- |
| OC_CONFIG_DIR | 配置文件夹路径 | ./data/config | 是 |
| OC_DATA_DIR | 数据文件夹路径 | ./data/storage | 是 |

### 配置目录结构

安装后，配置目录 (`OC_CONFIG_DIR`) 包含以下文件：

```
config/
├── csp.yaml                    # 内容安全策略配置
└── banned-password-list.txt    # 禁止使用的密码列表
```

升级或迁移前，请在 1Panel 中备份上述数据目录。确保数据目录的所有者为 UID:GID 1000:1000。

## 配置项

| 变量 | 说明 | 默认值 | 必填 |
| --- | --- | --- | --- |
| PANEL_APP_PORT_HTTP | 访问端口 | 8080 | 是 |
| OC_DOMAIN | 域名（可选） | - | 否 |
| INITIAL_ADMIN_PASSWORD | 管理员密码（首次启动后不可修改） | - | 是 |
| INSECURE | 跳过证书验证 | true | 是 |
| OC_CONTAINER_UID_GID | 容器内 UID:GID | 1000:1000 | 是 |
| TIME_ZONE | 时区 | Asia/Shanghai | 是 |
| DEFAULT_LANGUAGE | 默认语言 (ISO 639-1) | en | 否 |
| PROXY_ENABLE_BASIC_AUTH | 启用 Basic Auth (WebDAV) | false | 否 |
| LOG_PRETTY | 美化日志 | false | 否 |
| LOG_LEVEL | 日志级别 | info | 否 |
| DEMO_USERS | 创建演示用户 | false | 否 |
| CHECK_FOR_UPDATES | 检查更新 | true | 否 |
| START_ADDITIONAL_SERVICES | 额外启动的服务 | "" | 否 |

### 密码策略配置

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| OC_PASSWORD_POLICY_DISABLED | 禁用密码策略 | false |
| OC_PASSWORD_POLICY_MIN_CHARACTERS | 最小字符数 | 8 |
| OC_PASSWORD_POLICY_MIN_LOWERCASE_CHARACTERS | 最小小写字母数 | 1 |
| OC_PASSWORD_POLICY_MIN_UPPERCASE_CHARACTERS | 最小大写字母数 | 1 |
| OC_PASSWORD_POLICY_MIN_DIGITS | 最小数字数 | 1 |
| OC_PASSWORD_POLICY_MIN_SPECIAL_CHARACTERS | 最小特殊字符数 | 1 |

### SMTP 邮件配置

如需发送通知邮件，配置以下变量：

| 变量 | 说明 | 默认值 |
| --- | --- | --- |
| SMTP_HOST | SMTP 服务器 | - |
| SMTP_PORT | SMTP 端口 | - |
| SMTP_SENDER | 发件人地址 | - |
| SMTP_USERNAME | SMTP 用户名 | - |
| SMTP_PASSWORD | SMTP 密码 | - |
| SMTP_AUTHENTICATION | 认证方式 | - |
| SMTP_TRANSPORT_ENCRYPTION | 加密方式 (starttls/ssltls/none) | none |
| SMTP_INSECURE | 允许不安全连接 | false |

启用邮件通知还需设置 `START_ADDITIONAL_SERVICES=notifications`。

## 使用说明

### 基本使用

1. 安装完成后，通过浏览器访问 `http://服务器IP:端口`
2. 使用管理员账号登录（用户名：`admin`，密码：安装时设置的密码）
3. 可以创建用户、上传文件、共享文件夹等

### 高级配置

#### 在线文档编辑

OpenCloud 支持集成 Collabora Online 或 Euro Office 实现在线文档编辑：
- 需要额外配置 Collabora 或 Euro Office 容器
- 参考 [opencloud-compose](https://github.com/opencloud-eu/opencloud-compose) 官方文档

#### 全文搜索

启用 Apache Tika 实现全文搜索：
- 需要额外添加 Tika 容器
- 参考官方文档配置 `search/tika.yml`

#### S3 存储

OpenCloud 支持 S3 作为主存储后端：
- 配置 `DECOMPOSEDS3_*` 相关环境变量
- 参考 `storage/decomposeds3.yml`

### 生产环境建议

1. **使用域名和 HTTPS**：配置 `OC_DOMAIN` 并使用 Traefik/Nginx/Caddy 等反向代理
2. **设置 INSECURE=false**：生产环境关闭自签名证书跳过验证
3. **修改管理员密码**：首次登录后通过用户设置界面修改
4. **定期备份**：备份配置和数据目录
5. **权限设置**：确保 `OC_CONFIG_DIR` 和 `OC_DATA_DIR` 目录的所有者为 1000:1000

### 与 Nextcloud 的区别

OpenCloud 是 ownCloud Infinite Scale 的开源分支，专注于：
- 更简洁的架构（单一二进制文件，无需传统数据库）
- 更好的性能（Go 语言实现）
- 原生支持现代 Web 技术
- 更强的隐私和数据主权
- 模块化设计（可选组件按需加载）

## 参考资料

- 官网: <https://opencloud.eu>
- GitHub: <https://github.com/opencloud-eu/opencloud>
- 文档: <https://docs.opencloud.eu>
- Docker Compose 部署: <https://github.com/opencloud-eu/opencloud-compose>
- 发布说明: <https://docs.opencloud.eu/opencloud_release_notes.html>
