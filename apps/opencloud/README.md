# OpenCloud

[OpenCloud](https://opencloud.eu) 是一个开源的文件管理、共享与协作平台（ownCloud Infinite Scale 的欧洲社区分支），使用 Go 编写，单二进制、无需数据库，简洁且自主可控。

- 官网：https://opencloud.eu
- 源码：https://github.com/opencloud-eu/opencloud
- 部署参考：https://github.com/opencloud-eu/opencloud-compose
- 文档：https://docs.opencloud.eu

## 重要须知：OC_URL 必须是 HTTPS

OpenCloud 内置 OpenID Connect 身份认证，**访问地址（OC_URL）必须为 `https://` 且与浏览器实际访问的地址完全一致**，否则会出现登录跳转失败。本应用提供两种访问模式：

### 模式一：直连访问（默认，开箱即用）

安装时保持"内置自签名 HTTPS"为**是**，并把"访问地址"改为你实际访问的地址，例如：

```
https://192.168.1.100:9200
```

浏览器访问该地址，首次会提示自签名证书不受信任，选择"继续访问"即可。

### 模式二：域名 + 1Panel 反向代理（推荐生产使用）

1. 安装时把"内置自签名 HTTPS"设为**否**，"访问地址"填 `https://你的域名`（如 `https://cloud.example.com`）；
2. 在 1Panel「网站」中创建反向代理网站，域名指向 `127.0.0.1:<网页端口>`；
3. 为该网站申请/上传 SSL 证书并开启 HTTPS；
4. 如证书为正式证书，可将"跳过证书验证"改为否；
5. 此模式下应用端口是明文 HTTP 且监听所有网卡，建议在 1Panel「防火墙」中限制该端口仅允许本机（127.0.0.1）访问，只通过反向代理对外提供服务。

## 首次登录

- 用户名：`admin`
- 密码：安装表单中填写的"管理员密码"

> **注意**：管理员密码仅在**首次启动**时生效。之后修改该环境变量无效，只能通过 OpenCloud 界面或 CLI 修改，参见[官方说明](https://docs.opencloud.eu/docs/admin/resources/common-issues)。

## 数据目录

| 路径 | 说明 |
| --- | --- |
| `./data/config` | OpenCloud 配置（含首次生成的随机密钥，务必随数据一起备份） |
| `./data/storage` | 用户文件数据 |
| `./data/apps` | Web 扩展目录（放入扩展后重启容器生效） |

目录属主需为 `1000:1000`。安装脚本会自动创建上述目录并修正属主，包括在安装表单中自定义的路径；仅当安装后手动改挂载路径时才需要自行 `chown -R 1000:1000`。

## WebDAV 客户端

不支持 OpenID Connect 的 WebDAV 客户端需要在安装参数中启用 Basic Auth（有安全折衷，不推荐长期开启）。

## 常见问题

- **容器反复重启**：多为管理员密码未设置、或配置目录无写权限（属主不是 1000:1000）。
- **登录跳转到 localhost / 证书错误**：OC_URL 与浏览器访问地址不一致，改为一致后重启应用。
- **修改访问地址**：在应用参数中修改 OC_URL 并重启即可，已有数据不受影响。
