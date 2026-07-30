# OpenCloud

[OpenCloud](https://opencloud.eu) 是开源的文件管理、共享与协作平台。本应用以官方 [opencloud-compose](https://github.com/opencloud-eu/opencloud-compose) 为基准适配 1Panel，并保留 OpenCloud 内置 IDM，不需要额外数据库。

- 官网：https://opencloud.eu
- 源码：https://github.com/opencloud-eu/opencloud
- 官方部署仓库：https://github.com/opencloud-eu/opencloud-compose
- 文档：https://docs.opencloud.eu

## 版本说明

- `7.2.2` 使用生产镜像 `opencloudeu/opencloud:7.2.2`。
- `7.3.0` 和 `latest` 严格跟随当前官方 Compose，固定使用 `opencloudeu/opencloud-rolling:7.3.0`。生产镜像仓库目前没有 `7.3.0` 标签，因此没有使用不存在的 `opencloudeu/opencloud:7.3.0`。
- `latest` 使用固定版本号，不使用浮动 Docker 标签，避免同一应用版本在不同安装时间拉取到不同镜像。

## 安装前必读

`OC_URL` 必须使用 `https://`，并与用户在浏览器中实际访问的完整地址一致，包括域名和非标准端口。地址不一致会导致 OpenID Connect 登录跳转失败。

本应用支持两种官方部署方式。安装表单默认采用更适合生产环境的 1Panel 反向代理模式。

### 1Panel 反向代理（推荐）

安装表单使用以下配置：

| 配置 | 值 |
| --- | --- |
| 外部 HTTPS 访问地址 | `https://cloud.example.com` |
| 访问方式 / 宿主机监听地址 | `1Panel reverse proxy (127.0.0.1)` |
| OpenCloud 内置 TLS | `No` |
| 跳过 TLS 证书验证 | 可信证书选 `No`，自签名证书选 `Yes` |

安装后在 1Panel「网站」中创建反向代理网站，将整个域名代理到 `http://127.0.0.1:<网页端口>`，然后为网站申请或上传证书并开启 HTTPS。必须代理整个 OpenCloud 域名，不能遗漏 `/wopi` 和 `/collaboration` 路径。

此模式由 1Panel 终止 TLS，OpenCloud 与本机反代之间使用 HTTP。应用端口只绑定 `127.0.0.1`，不会将明文后端暴露到外网。证书由 1Panel 网站管理，不需要挂载到 OpenCloud 容器。

### 内置自签名 HTTPS 直连

安装表单使用以下配置：

| 配置 | 值 |
| --- | --- |
| 外部 HTTPS 访问地址 | `https://服务器地址:网页端口` |
| 访问方式 / 宿主机监听地址 | `Direct access (0.0.0.0)` |
| OpenCloud 内置 TLS | `Yes` |
| 跳过 TLS 证书验证 | `Yes` |

浏览器首次访问会提示自签名证书不受信任。此模式适合内网、测试或临时使用；公网生产环境建议使用 1Panel 反向代理和可信证书。

初始化脚本会拒绝 `PROXY_TLS=false` 且监听 `0.0.0.0` 的组合，避免把明文 OpenCloud 后端直接暴露到所有网卡。

## 首次登录

- 用户名：`admin`
- 密码：安装表单中的“管理员密码”

管理员密码只在首次初始化时生效。之后修改环境变量不会修改已有管理员密码，需通过 OpenCloud 用户设置或官方 CLI 修改。

## 邮件通知

要启用邮件通知，在“额外内置服务”中选择“邮件通知”，并完整填写 SMTP 主机、端口、发件人、认证和传输加密参数。SMTP 认证方式支持官方定义的 `auto`、`login`、`plain`、`crammd5` 和 `none`；传输加密支持 `none`、`starttls` 和 `ssltls`。

## 数据与权限

| 默认路径 | 内容 |
| --- | --- |
| `./data/config` | OpenCloud 配置和首次生成的随机密钥 |
| `./data/storage` | 用户文件数据 |
| `./data/apps` | OpenCloud Web 扩展 |

三个目录均可在首次安装表单中修改。容器默认以 `1000:1000` 运行，初始化脚本会创建目录并设置目录属主；安装时修改“容器 UID:GID”，目录属主也会同步使用新值。管理员初始密码、UID:GID 和数据目录安装后不允许直接通过 1Panel 参数编辑修改，因为修改这些值不等于重置密码或迁移已有数据。配置目录和数据目录必须一起备份。

## 本地存储与 S3

安装表单支持官方的两种用户文件主存储：

- “本地存储”使用 `./data/storage`，适合普通单机部署。
- “外部 S3”使用官方 `storage/decomposeds3.yml` 对应的驱动参数，不需要增加容器，但安装前必须准备 S3 端点、区域、Access Key、Secret Key 和存储桶。

系统配置等少量内部数据仍按官方要求保存在本地配置和数据目录中，因此使用 S3 时也必须备份这些目录。存储驱动仅允许在首次安装时选择；切换驱动不会自动迁移文件，已有实例不得直接改参数切换。

## 官方扩展范围

当前 1Panel 应用是 OpenCloud 单容器部署，安装表单覆盖官方主 Compose 的全部直接可用参数，并额外支持无需新增容器的官方 S3 配置。以下官方能力需要对应的补充 Compose 文件、独立容器、域名或配置文件，因此没有做成无法工作的单个开关：

- Collabora / Euro Office 在线编辑
- ClamAV 杀毒和 Apache Tika 全文提取
- 外部 LDAP、Keycloak / OIDC 身份源
- Radicale 日历与联系人
- Traefik、Prometheus、外部 NATS、MinIO 测试服务

后续如接入这些能力，应按官方 Compose 的服务组合单独扩展应用，而不是只向主容器传入环境变量。

## 安全选项

- 演示用户的密码是公开的，生产环境必须保持关闭。
- Basic Auth 仅用于不支持 OpenID Connect 的旧式 WebDAV 客户端，官方不建议在生产环境启用。
- 公共分享密码要求和密码复杂度均可在安装表单中调整，默认值与官方 Compose 一致。

## 常见问题

- **容器反复重启**：检查管理员密码是否在首次安装时设置，以及配置、数据、扩展目录是否允许表单中的 UID:GID 写入。
- **登录跳转到错误域名或 localhost**：确认 `OC_URL` 与浏览器地址完全一致，然后重启应用。
- **1Panel 反代出现 502**：确认反代目标使用 `http://127.0.0.1:<网页端口>`，且应用监听地址为 `127.0.0.1`、内置 TLS 为 `No`。
- **直连提示协议错误**：确认监听地址为 `0.0.0.0`、内置 TLS 和跳过证书验证均为 `Yes`。
- **邮件不发送**：确认额外内置服务包含 `notifications`，并检查 SMTP 加密方式、认证方式和发件人地址。
