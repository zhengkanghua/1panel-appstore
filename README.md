# 1Panel 本地应用商店

适配 [1Panel](https://1panel.cn) 应用商店 `2.0` 的本地应用（Local Apps）仓库。收录官方商店与常见第三方仓库（如 [okxlin/appstore](https://github.com/okxlin/appstore)）尚未纳入、但我们需要的开源项目。

导入后可在 1Panel「应用商店 → 本地应用」中直接安装，也可以进入应用版本目录用 `docker compose` 手动运行。

## 应用列表

| 应用 | 说明 | 版本 |
| --- | --- | --- |
| [OpenCloud](apps/opencloud/README.md) | 开源文件管理、共享与协作平台（oCIS 欧洲社区分支） | 7.2.2 / latest |

## 使用方式（标准流程）

在 1Panel「计划任务」中新建一个 **Shell 脚本** 任务（如每天执行一次），内容如下，实现仓库到本地应用目录的定时同步。以下命令默认 1Panel 安装在 `/opt`；如果安装位置不同，只需修改 `PANEL_BASE_DIR`：

```bash
set -euo pipefail

PANEL_BASE_DIR="/opt"

case "$PANEL_BASE_DIR" in
  /*) ;;
  *)
    echo "PANEL_BASE_DIR 必须是绝对路径" >&2
    exit 1
    ;;
esac

PANEL_BASE_DIR="$(realpath -m -- "$PANEL_BASE_DIR")"
if [ "$PANEL_BASE_DIR" = "/" ]; then
  echo "PANEL_BASE_DIR 不能是 /" >&2
  exit 1
fi

LOCAL_APPS_DIR="$PANEL_BASE_DIR/1panel/resource/apps/local"
IMPORT_DIR="$PANEL_BASE_DIR/1panel/resource/apps/1panel-appstore-tmp"

if [ ! -d "$LOCAL_APPS_DIR" ]; then
  echo "1Panel 本地应用目录不存在: $LOCAL_APPS_DIR" >&2
  exit 1
fi

cleanup() {
  if [ -d "$IMPORT_DIR" ] && [ ! -L "$IMPORT_DIR" ]; then
    find "$IMPORT_DIR" -xdev -mindepth 1 -delete
    rmdir "$IMPORT_DIR"
  fi
}

if [ -e "$IMPORT_DIR" ] || [ -L "$IMPORT_DIR" ]; then
  if [ -L "$IMPORT_DIR" ] || [ ! -d "$IMPORT_DIR" ]; then
    echo "临时路径不是普通目录, 请手动检查: $IMPORT_DIR" >&2
    exit 1
  fi
  cleanup
fi

trap cleanup EXIT
git clone --depth 1 https://github.com/zhengkanghua/1panel-appstore.git "$IMPORT_DIR"
cp -a "$IMPORT_DIR/apps/." "$LOCAL_APPS_DIR/"
```

首次可手动执行一次该任务，然后在 1Panel「应用商店 → 本地应用」中点击**更新应用列表**，即可看到本仓库的应用，直接点安装。安装时 1Panel 会自动：按表单生成 `.env` → 执行 `scripts/init.sh`（初始化数据目录与权限）→ `docker compose up`，无需登录服务器手动操作。

### 调试用：脱离 1Panel 手动 docker compose

仅用于开发调试或不使用 1Panel 的场景（`.env.sample` 即为此准备）：

```shell
cd apps/opencloud/latest
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
