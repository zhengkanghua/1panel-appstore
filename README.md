# 1Panel 本地应用商店

适配 [1Panel](https://1panel.cn) 应用商店 `2.0` 的本地应用（Local Apps）仓库。收录官方商店与常见第三方仓库（如 [okxlin/appstore](https://github.com/okxlin/appstore)）尚未纳入、但我们需要的开源项目。

导入后可在 1Panel「应用商店 → 本地应用」中直接安装，也可以进入应用版本目录用 `docker compose` 手动运行。

## 应用列表

| 应用 | 说明 | 版本 |
| --- | --- | --- |
| [OpenCloud](apps/opencloud/README.md) | 开源文件管理、共享与协作平台（oCIS 欧洲社区分支） | 7.2.2 / latest |

## 使用方式

以下命令假设 1Panel 安装在默认的 `/opt` 路径，其他路径请自行调整。

### 方式一：git clone

在 1Panel 计划任务（Shell 脚本）或服务器终端中执行：

```shell
git clone https://github.com/zhengkh/1panel-appstore /opt/1panel/resource/apps/local/1panel-appstore-tmp
cp -rf /opt/1panel/resource/apps/local/1panel-appstore-tmp/apps/* /opt/1panel/resource/apps/local/
rm -rf /opt/1panel/resource/apps/local/1panel-appstore-tmp
```

然后在 1Panel「应用商店 → 本地应用」中点击**更新应用列表**。

### 方式二：手动 docker compose

```shell
cd /opt/1panel/resource/apps/local/opencloud/latest
cp .env.sample .env
# 编辑 .env, 至少设置 OC_URL 和 INITIAL_ADMIN_PASSWORD
bash scripts/init.sh
docker compose up -d
```

## 目录规范

遵循 1Panel v2 本地应用规范：

```
apps/
└── <应用key>/
    ├── data.yml              # 应用声明: 名称、描述(多语言)、标签、官网等
    ├── logo.png              # 应用图标 (180x180)
    ├── README.md             # 应用说明文档
    └── <版本号>/              # 版本目录 (不要以 v 开头), 及 latest/
        ├── data.yml          # 安装表单 formFields 定义
        ├── docker-compose.yml
        ├── .env.sample       # 手动部署用的环境变量样例
        ├── init/             # 需要挂载进容器的初始配置文件
        └── scripts/          # 生命周期钩子: init.sh / upgrade.sh / uninstall.sh
```

## 贡献应用

1. 优先参考项目**官方** docker compose 配置进行适配；
2. `docker-compose.yml` 必须加入 `1panel-network`（external）、`container_name: ${CONTAINER_NAME}`、`labels: createdBy: "Apps"`；
3. 端口类表单变量使用 `PANEL_APP_PORT_HTTP` 等约定 envKey，并设置 `rule: paramPort`；
4. 表单 `label` 提供多语言（至少 zh / en）；
5. 提交前建议用 [okxlin/1panel-app-adapter](https://github.com/okxlin/1panel-app-adapter) 校验目录结构与 data.yml。

## 致谢

- [1Panel](https://github.com/1Panel-dev/1Panel)
- [okxlin/appstore](https://github.com/okxlin/appstore) — 目录规范与适配方式参考

## License

[MIT](LICENSE)
