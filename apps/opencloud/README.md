# OpenCloud

## 应用简介

OpenCloud 是一个开源的文件管理、共享和协作平台，简洁且自主可控。

英文说明：OpenCloud is the open source platform for file management, sharing and collaboration. Simple and sovereign.

## 部署说明

- 本应用使用 Docker Compose 在 1Panel 中部署。
- 应用分类：网站。
- 支持架构：amd64, arm64。
- 使用 `opencloudeu/opencloud-rolling` 镜像（滚动更新版本）。
- 安装后可通过 Web 浏览器访问 OpenCloud 界面。

## 首次运行

1. 部署完成后，通过配置的端口访问 OpenCloud。
2. 默认管理员用户名：`admin`
3. 管理员密码：在安装时设置的密码。
4. 首次登录后建议修改管理员密码。

## 端口

| 变量 | 说明 | 默认值 | 必填 |
| --- | --- | --- | --- |
| PANEL_APP_PORT_HTTP | HTTP端口 | 8080 | 是 |

## 数据持久化

| 变量 | 说明 | 默认值 | 必填 |
| --- | --- | --- | --- |
| OC_CONFIG_PATH | 配置文件夹路径 | ./data/config | 是 |
| OC_DATA_PATH | 数据文件夹路径 | ./data/storage | 是 |

升级或迁移前，请在 1Panel 中备份上述数据目录。

## 配置项

| 变量 | 说明 | 默认值 | 必填 |
| --- | --- | --- | --- |
| OC_DOMAIN | 域名 | - | 否 |
| INITIAL_ADMIN_PASSWORD | 管理员密码 | admin | 是 |
| TIME_ZONE | 时区 | Asia/Shanghai | 是 |
| INSECURE | 跳过证书验证 | true | 是 |

## 使用说明

### 基本使用

- 安装完成后，通过浏览器访问 `http://服务器IP:端口`
- 使用管理员账号登录（用户名：`admin`，密码：安装时设置的密码）
- 可以创建用户、上传文件、共享文件夹等

### 生产环境建议

1. **使用域名和反向代理**：配置 `OC_DOMAIN` 并使用 Nginx/Caddy 等反向代理
2. **启用 HTTPS**：在反向代理中配置 SSL 证书
3. **修改管理员密码**：首次登录后立即修改
4. **定期备份**：备份配置和数据目录

### 与 Nextcloud 的区别

OpenCloud 是 ownCloud Infinite Scale 的开源分支，专注于：
- 更简洁的架构
- 更好的性能
- 原生支持现代 Web 技术
- 更强的隐私和数据主权

## 参考资料

- 官网: <https://opencloud.eu>
- GitHub: <https://github.com/opencloud-eu/opencloud>
- 文档: <https://docs.opencloud.eu>
- Docker Compose 部署: <https://github.com/opencloud-eu/opencloud-compose>
