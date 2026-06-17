# Generator-KV — SoloMktKV 活动主视觉海报生成插件 | Activity KV Key Visual Poster Generator

[English](#english) | [中文](#chinese)

---

<a id="english"></a>

## English

### Overview

**Generator-KV** is a Claude Code plugin that generates activity KV (Key Visual) posters via the SoloMktKV API. It helps marketers, event planners, and designers quickly create stunning promotional key visuals by simply describing their event — no design skills needed.

### Features

- 🔑 **Auto API Key Configuration** — On first use, prompts you to enter your API key and saves it securely
- 🎨 **Model List Browsing** — Fetches available style models from the API, letting you preview and choose the perfect visual style
- 📝 **Guided Input** — Asks for activity name, theme, time, and location step by step
- 🖼️ **One-Click Generation** — Calls the SoloMktKV API to generate professional KV posters
- 🔒 **Secure Storage** — API keys are stored locally in `${CLAUDE_PLUGIN_DATA}/auth.json` and only sent to the configured API server
- 🚀 **Session Reminder** — Automatically checks API key status on session start

### Installation

#### Prerequisites

- [Claude Code](https://claude.ai/code) installed
- A valid SoloMktKV API Key (`x-api-key`) — contact your system administrator to obtain one

#### Method 1: Install from Marketplace (Recommended)

```bash
# 1. Add the SoloMkt-KV marketplace
claude plugin marketplace add wolf521/SoloMktKV-ClaudeCode

# 2. Install the generator-kv plugin from the marketplace
claude plugin install generator-kv@SoloMkt-KV
```

#### Method 2: Install from GitHub Directly

```bash
# Install directly from the GitHub repository
claude plugin install generator-kv@wolf521/SoloMktKV-ClaudeCode
```

### Usage

```
/generator-kv:generate-kv <activity_name>
```

**Example:**

```
/generator-kv:generate-kv 第四届中国国际供应链促进博览会
```

The plugin will then:
1. Check if your API key is configured (prompt you to enter it if not)
2. Fetch available style models from the API
3. Let you choose a visual style
4. Ask for activity details (theme, time, location)
5. Optionally ask for supplementary prompt, quality, and size preferences
6. Generate the KV poster and return the image URLs

### Configuration

The plugin stores your API credentials in `${CLAUDE_PLUGIN_DATA}/auth.json`:

```json
{
  "base_url": "https://solosmart-uat.issmart.com.cn",
  "x-api-key": "your-api-key-here",
  "created_at": "2026-04-10T00:00:00.000Z",
  "source": "auto_provisioned"
}
```

To manually configure or update your API key, edit this file or simply run `/generator-kv:generate-kv` — the plugin will detect missing credentials and guide you through setup.

### Uninstallation

```bash
# Remove the plugin
claude plugin uninstall generator-kv

# (Optional) Remove the marketplace
claude plugin marketplace remove SoloMkt-KV
```

Note: Uninstalling the plugin does NOT delete your `${CLAUDE_PLUGIN_DATA}/auth.json` file. To completely remove all data, manually delete the auth file.

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/solomkt_kv/api/v1/models?type=all` | GET | Fetch available style models |
| `/solomkt_kv/api/v1/generatekV` | POST | Generate KV poster images |

### Repository

- **GitHub**: [https://github.com/wolf521/SoloMktKV-ClaudeCode](https://github.com/wolf521/SoloMktKV-ClaudeCode)
- **Marketplace**: SoloMkt-KV
- **Plugin Name**: generator-kv
- **Author**: [wolf521](https://github.com/wolf521)

### License

MIT License — see [LICENSE](LICENSE) file for details.

---

<a id="chinese"></a>

## 中文

### 概述

**Generator-KV** 是一款 Claude Code 插件，通过 SoloMktKV API 生成活动 KV（主视觉）海报。帮助市场营销人员、活动策划者和设计师通过简单描述活动信息，快速生成专业的主视觉图像——无需设计技能。

### 功能特点

- 🔑 **自动配置 API Key** — 首次使用时提示输入 API Key 并安全保存
- 🎨 **模型列表浏览** — 从 API 获取可用风格模型列表，预览并选择最适合的视觉风格
- 📝 **引导式输入** — 逐步引导填写活动名称、主题、时间、地点
- 🖼️ **一键生成** — 调用 SoloMktKV API 生成专业 KV 海报
- 🔒 **安全存储** — API Key 仅存储在本地 `${CLAUDE_PLUGIN_DATA}/auth.json`，仅发送至配置的 API 服务器
- 🚀 **会话提醒** — 会话启动时自动检查 API Key 配置状态

### 安装

#### 前置条件

- 已安装 [Claude Code](https://claude.ai/code)
- 拥有有效的 SoloMktKV API Key（`x-api-key`）—— 联系系统管理员获取

#### 方式一：从插件市场安装（推荐）

```bash
# 1. 添加 SoloMkt-KV 插件市场
claude plugin marketplace add wolf521/SoloMktKV-ClaudeCode

# 2. 从市场安装 generator-kv 插件
claude plugin install generator-kv@SoloMkt-KV
```

#### 方式二：从 GitHub 直接安装

```bash
# 直接从 GitHub 仓库安装
claude plugin install generator-kv@wolf521/SoloMktKV-ClaudeCode
```

### 使用方式

```
/generator-kv:generate-kv <活动名称>
```

**示例：**

```
/generator-kv:generate-kv 第四届中国国际供应链促进博览会
```

插件将按以下流程运行：
1. 检查 API Key 是否已配置（如未配置则引导输入）
2. 从 API 获取可用风格模型
3. 让你选择喜欢的视觉风格
4. 引导填写活动详情（主题、时间、地点）
5. 可选填写补充提示词、图片质量与尺寸偏好
6. 生成 KV 海报并返回图片链接

### 配置说明

插件将 API 凭证存储在 `${CLAUDE_PLUGIN_DATA}/auth.json`：

```json
{
  "base_url": "https://solosmart-uat.issmart.com.cn",
  "x-api-key": "你的-api-key",
  "created_at": "2026-04-10T00:00:00.000Z",
  "source": "auto_provisioned"
}
```

如需手动配置或更新 API Key，可直接编辑此文件，或直接运行 `/generator-kv:generate-kv` —— 插件会自动检测缺失的凭证并引导完成配置。

### 卸载

```bash
# 卸载插件
claude plugin uninstall generator-kv

# （可选）移除插件市场
claude plugin marketplace remove SoloMkt-KV
```

注意：卸载插件不会删除 `${CLAUDE_PLUGIN_DATA}/auth.json` 文件。如需彻底清除所有数据，请手动删除该文件。

### API 接口

| 接口 | 请求方式 | 说明 |
|------|----------|------|
| `/solomkt_kv/api/v1/models?type=all` | GET | 获取可用风格模型列表 |
| `/solomkt_kv/api/v1/generatekV` | POST | 生成 KV 主视觉图片 |

### 仓库信息

- **GitHub 仓库**: [https://github.com/wolf521/SoloMktKV-ClaudeCode](https://github.com/wolf521/SoloMktKV-ClaudeCode)
- **插件市场名称**: SoloMkt-KV
- **插件名称**: generator-kv
- **作者**: [wolf521](https://github.com/wolf521)

### 开源协议

MIT License — 详见 [LICENSE](LICENSE) 文件。
