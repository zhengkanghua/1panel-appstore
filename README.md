# 1Panel 本地应用商店

适配 [1Panel](https://1panel.cn) 应用商店 `2.0` 的本地应用（Local Apps）仓库。收录官方商店与常见第三方仓库（如 [okxlin/appstore](https://github.com/okxlin/appstore)）尚未纳入、但我们需要的开源项目。

导入后可在 1Panel「应用商店 → 本地应用」中直接安装，也可以进入应用版本目录用 `docker compose` 手动运行。

## 应用列表

| 应用 | 说明 | 版本 |
| --- | --- | --- |
| [OpenCloud](apps/opencloud/README.md) | 开源文件管理、共享与协作平台（oCIS 欧洲社区分支） | 7.2.2 / 7.3.0（latest 为兼容入口） |

## 使用方式（标准流程）

在 1Panel「计划任务」中新建一个 **Shell 脚本** 任务（如每天执行一次），内容如下，实现仓库到本地应用目录的定时同步。以下命令默认 1Panel 安装在 `/opt`；如果安装位置不同，只需修改 `PANEL_BASE_DIR`：

```bash
#!/bin/bash

rm -rf /opt/1panel/resource/apps/local/1panel-appstore-tmp
git clone --depth 1 https://github.com/zhengkanghua/1panel-appstore /opt/1panel/resource/apps/local/1panel-appstore-tmp || exit 1
cp -rf /opt/1panel/resource/apps/local/1panel-appstore-tmp/apps/* /opt/1panel/resource/apps/local/
rm -rf /opt/1panel/resource/apps/local/1panel-appstore-tmp
```

首次可手动执行一次该任务，然后在 1Panel「应用商店 → 本地应用」中点击**更新应用列表**，即可看到本仓库的应用，直接点安装。安装时 1Panel 会自动：按表单生成 `.env` → 执行 `scripts/init.sh`（初始化数据目录与权限）→ `docker compose up`，无需登录服务器手动操作。

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

## 致谢

- [1Panel](https://github.com/1Panel-dev/1Panel)
- [okxlin/appstore](https://github.com/okxlin/appstore) — 目录规范与适配方式参考

## License

[MIT](LICENSE)
