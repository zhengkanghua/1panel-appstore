# 1Panel 本地应用商店

这是一个为 1Panel v2.0+ 设计的本地应用商店仓库。

## 简介

1Panel 从 2.0 版本开始支持本地应用功能，允许用户创建和使用自定义的应用模板。本仓库旨在提供一个开源的本地应用集合，补充官方应用商店中缺失的应用。

## 参考来源

- [okxlin/appstore](https://github.com/okxlin/appstore) - 第三方应用商店，提供了丰富的应用模板
- [1Panel 官方应用商店](https://github.com/1Panel-dev/appstore) - 1Panel 官方应用商店

## 为什么创建这个仓库？

虽然 [okxlin/appstore](https://github.com/okxlin/appstore) 提供了大量优质应用，但某些开源项目并未被纳入。例如：
- [OpenCloud](https://github.com/opencloud-eu/opencloud) - 开源文件管理与协作平台

本仓库的目标是：
1. 补充官方和第三方商店中缺失的开源应用
2. 提供高质量、易用的应用模板
3. 促进社区贡献

## 仓库结构

```
apps/
├── app-name/
│   ├── data.yml          # 应用元数据（名称、描述、分类等）
│   ├── logo.png          # 应用图标
│   ├── README.md         # 应用说明文档
│   └── latest/           # 版本目录（可有多个版本）
│       ├── data.yml      # 表单字段配置
│       ├── docker-compose.yml  # Docker Compose 配置
│       ├── .env.sample   # 环境变量示例
│       └── init/         # 初始化配置文件
│           ├── csp.yaml
│           └── ...
```

## 应用列表

| 应用 | 描述 | 状态 |
| --- | --- | --- |
| [OpenCloud](apps/opencloud/) | 开源文件管理与协作平台 | ✅ 可用 |

## 如何使用

### 方法一：添加到 1Panel

1. 在 1Panel 中进入「应用商店」→「本地应用」
2. 点击「设置」→「添加应用商店」
3. 填写仓库地址：`https://github.com/your-username/1panel-appstore.git`
4. 保存后即可在本地应用中看到可用的应用

### 方法二：手动部署

1. 克隆本仓库到本地
2. 复制需要的应用目录到 1Panel 的应用目录
3. 在 1Panel 中刷新本地应用列表

## 如何贡献

欢迎贡献新的应用模板！

### 贡献步骤

1. Fork 本仓库
2. 创建新的应用目录（参考现有应用结构）
3. 填写完整的元数据和文档
4. 测试应用是否可以正常部署
5. 提交 Pull Request

### 应用模板要求

- `data.yml` 必须包含完整的元数据（多语言支持）
- `docker-compose.yml` 必须使用 1Panel 的变量格式
- 提供清晰的 `README.md` 文档
- 应用图标建议使用 PNG 格式，尺寸不小于 128x128

## 许可证

本仓库采用 [MIT License](LICENSE) 开源许可证。

## 相关链接

- [1Panel 官网](https://1panel.pro/)
- [1Panel GitHub](https://github.com/1Panel-dev/panel)
- [okxlin/appstore](https://github.com/okxlin/appstore)
