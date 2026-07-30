# 应用升级维护指南

本文以 OpenCloud 为例，说明上游发布新版本时，本仓库需要做什么。其他应用照同样流程维护。

每个应用有**两个上游**，升级时分别对应两类工作：

| 上游 | 变化频率 | 对应工作 |
| --- | --- | --- |
| Docker 镜像（[production](https://hub.docker.com/r/opencloudeu/opencloud/tags) / [rolling](https://hub.docker.com/r/opencloudeu/opencloud-rolling/tags)） | 高（每月数次） | 新建版本目录、核对镜像发布线和 tag |
| 官方 compose 配置仓库（[opencloud-compose](https://github.com/opencloud-eu/opencloud-compose)） | 低（大版本前后） | 对照 diff 同步配置 —— 需要人工判断 |

> **注意区分两条镜像发布线**：`opencloudeu/opencloud` 是生产发布线，`opencloudeu/opencloud-rolling` 是滚动发布线。优先使用生产线；只有在 GitHub 已有同版本正式 tag、官方 compose 固定使用该 rolling tag、且生产仓库确实没有对应 tag 时，才可发布 rolling 版本，并必须在应用 README 中明确说明。禁止构造不存在的生产镜像 tag。

每个应用目录下的 `.upstream` 文件记录了上次同步时上游仓库的 commit，是判断"上游有没有 diff"的基准点。

## 第一步：发现新版本

分别查询两个官方镜像仓库的 tag：

```bash
curl -s "https://hub.docker.com/v2/repositories/opencloudeu/opencloud/tags?page_size=10&ordering=last_updated" | python3 -c "import json,sys; [print(t['name'], t['last_updated'][:10]) for t in json.load(sys.stdin)['results']]"
curl -s "https://hub.docker.com/v2/repositories/opencloudeu/opencloud-rolling/tags?page_size=10&ordering=last_updated" | python3 -c "import json,sys; [print(t['name'], t['last_updated'][:10]) for t in json.load(sys.stdin)['results']]"
```

取完整语义化版本号，忽略 `latest`、`7`、`7.3` 这类浮动 tag 和 `-beta`/`-rc` 预发布版本。再核对 OpenCloud GitHub tag 与官方 compose 当前固定版本，记录最终使用 production 还是 rolling 镜像。

## 第二步：判断上游 compose 仓库是否有 diff

```bash
git clone https://github.com/opencloud-eu/opencloud-compose /tmp/oc-compose
cd /tmp/oc-compose

# LAST 取自本仓库 apps/opencloud/.upstream 的 last_synced_commit
LAST=8d2d89f283faa410bc9ed9f63e8247f6518d5c43

git diff --stat $LAST..HEAD -- docker-compose.yml .env.example external-proxy/opencloud.yml storage/decomposeds3.yml config/opencloud/
```

只需要关注 `.upstream` 中 `watched_files` 列出的文件。diff 为空走情况 A，不为空走情况 B。

## 情况 A：上游无 diff（常态，约 2 分钟）

只是镜像出了新版本，配置接口没变。以下以新建版本目录为例：

```bash
cd apps/opencloud

# 1. 复制版本目录
cp -r 7.2.2 7.3.0

# 2. 改成上一步确认存在的官方镜像和固定 tag
sed -i 's#opencloudeu/opencloud:7.2.2#opencloudeu/opencloud-rolling:7.3.0#' 7.3.0/docker-compose.yml
```

3. 更新根 `README.md` 应用列表中的版本号；
4. 更新应用 README 的版本发布线说明；
5. 顺手更新 `.upstream` 的 `last_synced_commit` 为刚才 `/tmp/oc-compose` 的 `git rev-parse HEAD`（虽然无 diff，但推进基准点能让下次 diff 范围更小）。

然后跳到[第三步：校验](#第三步校验)。

## 情况 B：上游有 diff（需要人工判断）

先读 diff 内容和上游 [CHANGELOG / Release Notes](https://docs.opencloud.eu/opencloud_release_notes.html)，再按下表把变更落到本仓库对应文件。**所有修改只做在新建的版本目录里**（先按情况 A 的步骤 1-2 建好新版本目录），不要回改已发布的旧版本目录。

| 上游文件的变化 | 本仓库落点 | 处理方式 |
| --- | --- | --- |
| `docker-compose.yml` 环境变量增/删/改名 | `<新版本>/docker-compose.yml` | 同步变量名和默认值；注意我们比上游多了 1Panel 约定（`1panel-network`、`container_name`、端口映射、`PROXY_TLS`/`OC_URL` 直连模式），这些要保留 |
| `docker-compose.yml` 挂载路径 / 入口命令变化 | `<新版本>/docker-compose.yml` | 同步；上游 `./config/opencloud/...` 路径对应本仓库 `./init/...` |
| `storage/decomposeds3.yml` 环境变量变化 | `<新版本>/docker-compose.yml` + `data.yml` | 同步 S3 驱动变量、安装表单和首次启动校验 |
| `.env.example` 新增配置项 | `<新版本>/.env.sample` | 补进样例并写中文注释；若是普通用户安装时就该决定的选项，再加入 `<新版本>/data.yml` 的 formFields（带多语言 label） |
| `config/opencloud/csp.yaml` 变化 | `<新版本>/init/csp.yaml` | 直接整文件覆盖 |
| `config/opencloud/banned-password-list.txt` 变化 | `<新版本>/init/banned-password-list.txt` | 直接整文件覆盖 |
| 行为/架构变化（如某服务收编进主进程、默认端口调整） | `apps/opencloud/README.md` | 更新使用说明和常见问题 |
| 出现**破坏性变更**（老数据需迁移、变量强制改名） | `apps/opencloud/README.md` + 版本目录 `scripts/upgrade.sh` | README 写明迁移步骤；能自动化的迁移动作写进 `upgrade.sh`（1Panel 升级时执行） |

同步完成后：

```bash
# 更新同步基准点
cd /tmp/oc-compose && git rev-parse HEAD
# 把输出写入 apps/opencloud/.upstream 的 last_synced_commit, 并更新 last_synced_date
```

## 第三步：校验

```bash
# YAML 语法 + 表单变量闭包检查（在仓库根目录执行）
python3 - <<'EOF'
import yaml, re, io, glob, sys
ok = True
for f in glob.glob('apps/*/data.yml') + glob.glob('apps/*/*/data.yml') + glob.glob('apps/*/*/docker-compose.yml'):
    yaml.safe_load(io.open(f, encoding='utf-8')); print('YAML OK', f)
for compose_f in glob.glob('apps/*/*/docker-compose.yml'):
    d = compose_f.rsplit('/', 1)[0]
    compose = io.open(compose_f, encoding='utf-8').read()
    used = set(re.findall(r'\$\{(\w+)(?::-[^}]*)?\}', compose))
    withdef = set(re.findall(r'\$\{(\w+):-[^}]*\}', compose))
    form = yaml.safe_load(io.open(d + '/data.yml', encoding='utf-8'))
    formkeys = {x['envKey'] for x in form['additionalProperties']['formFields']}
    envsample = set(re.findall(r'^(\w+)=', io.open(d + '/.env.sample', encoding='utf-8').read(), re.M))
    dangling = used - withdef - formkeys - envsample - {'CONTAINER_NAME'}
    if dangling:
        ok = False; print('!! 变量既无默认值也不在表单/.env.sample 中:', d, sorted(dangling))
sys.exit(0 if ok else 1)
EOF
```

有 Docker 环境时再跑一次 compose 渲染检查：

```bash
cd apps/opencloud/7.3.0 && cp .env.sample .env && sed -i 's/INITIAL_ADMIN_PASSWORD=""/INITIAL_ADMIN_PASSWORD="Test-1234"/' .env && docker compose config --quiet && echo OK; rm -f .env
```

**情况 B 必须做实机验收**：把应用目录拷到测试机 `/opt/1panel/resource/apps/local/`，商店里更新应用列表后走一遍全新安装 + 从旧版本升级，确认能登录、老数据完好。情况 A 可以抽查。

## 第四步：发布

1. 提交并推送（commit message 写明 `opencloud: bump to 7.3.0`，情况 B 附上游变更摘要）；
2. 用户侧重新执行根 README 的导入命令、在商店里"更新应用列表"后，已安装用户会看到"可升级"按钮，点击即走 1Panel 原生升级流程。

## 版本目录保留策略

- 保留**最近 2 个**固定版本目录 + `latest/`，更早的删除（Git 历史里永远可以找回）；
- `latest/` 只改配置结构、不改 tag：情况 B 同步配置时记得把同样的改动应用到 `latest/`；
- 不发布 beta / rc 版本目录。
