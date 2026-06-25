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
claude plugin marketplace add SoloMkt-KV/SoloMktKV-ClaudeCode

# 2. Install the generator-kv plugin from the marketplace
claude plugin install generator-kv@SoloMkt-KV
```

#### Method 2: Install from GitHub Directly

```bash
# Install directly from the GitHub repository
claude plugin install generator-kv@SoloMkt-KV/SoloMktKV-ClaudeCode
```

### Usage

#### Method 1: Slash Command

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

#### Method 2: Natural Language Conversation

You don't need to remember the exact command format — just talk to Claude in natural language! The plugin will automatically recognize your intent and guide you through the generation process.

**Examples:**

| Trigger | Example |
|---------|---------|
| Chinese | `帮我生成一张【活动描述】的KV` |
| Chinese | `为我们的【活动名称】制作一张主视觉海报` |
| English | `Help me generate a KV poster for [activity description]` |
| English | `Create a key visual for our [event name]` |

As long as your request mentions generating a KV, key visual poster, or activity poster, the plugin will automatically activate and walk you through each step — no slash command needed.

### Configuration

The plugin stores your API credentials in `${CLAUDE_PLUGIN_DATA}/auth.json`:

```json
{
  "base_url": "https://api.kv.solomarketing.com.cn",
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

| Endpoint | Method | Description |  Timeout Recommendation |
|----------|--------|-------------|------------------------------|
| `/api/v1/models?type=all` | GET | Fetch available style models | N/A (quick response) |
| `/api/v1/generateKV` | POST | Generate KV poster images | **30 minutes** (generation may take a long time) |

> For the `POST /api/v1/generateKV` endpoint, the image generation process can be computationally intensive and may take up to **30 minutes** depending on model complexity and queue load. **Clients MUST set a socket/request timeout of at least 30 minutes** to prevent premature connection termination. The plugin will automatically handle this timeout internally when calling the API.

### Error Handling & Auto-Recovery

When calling `POST /api/v1/generateKV`, if the server returns an error, the response body follows this structure:

```json
{
  "success": false,
  "error": {
    "code": "GENERATION_ENCODING_ERROR",
    "message": "...",
    "details": {
      "fieldName": "activityName",
      "reason": "...",
      "suggestion": "...",
      "rejectedValue": null
    }
  }
}
```

The model must automatically recover based on `error.code` and retry, instead of showing the raw error to the user.

| Error Code | Meaning | Auto-Recovery Action |
|---|---|---|
| `GENERATION_ENCODING_ERROR` | Non-UTF-8 bytes in request body | Convert the value of the field indicated by `fieldName` to UTF-8, ensure `Content-Type: application/json; charset=utf-8`, then retry |
| `GENERATION_JSON_PARSE_ERROR` | Invalid JSON format | Inspect request body JSON syntax, quotes, and field types, then retry |
| `GENERATION_FIELD_REQUIRED` | Required field missing | Prompt the user for the field indicated by `fieldName`, then retry |
| `GENERATION_FIELD_TOO_LONG` | Field value too long | Shorten the field indicated by `fieldName` to within its limit, then retry |
| `INVALID_MODEL` | Invalid `modelId` | Call `GET /api/v1/models?type=all` to refresh the model list, let the user pick a valid model, then retry |
| `QUOTA_EXCEEDED` | Daily quota exhausted | Stop retrying; inform the user that the daily quota is used up and suggest retrying the next day or contacting the admin |
| `UNAUTHORIZED` | Invalid `x-api-key` | Stop retrying; guide the user to check or reconfigure the API Key |
| `INTERNAL_ERROR` | Server internal error | Retry up to 2 times; if still failing, report to the user and stop |
| `TIMEOUT_ERROR` (client-side) | Request timed out (e.g., 408 or socket timeout) | The plugin will automatically detect timeout and **retry once** if the server does not return a definitive failure. If the second attempt also times out, inform the user and suggest trying again later or contact support. |

Auto-recovery principles:
- Always read `error.details.suggestion` first and follow it.
- After fixing, call `POST /api/v1/generateKV` again with the same `x-api-key`.
- Do not modify `x-api-key` or other valid fields.
- If auto-recovery fails twice in a row, stop and clearly inform the user.
- **[NEW]** For timeout errors, the plugin will not repeatedly retry beyond one additional attempt to avoid overloading the server.

### Repository

- **GitHub**: [https://github.com/SoloMkt-KV/SoloMktKV-ClaudeCode](https://github.com/SoloMkt-KV/SoloMktKV-ClaudeCode)
- **Marketplace**: SoloMkt-KV
- **Plugin Name**: generator-kv
- **Author**: [SoloMkt-KV](https://github.com/SoloMkt-KV)

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
claude plugin marketplace add SoloMkt-KV/SoloMktKV-ClaudeCode

# 2. 从市场安装 generator-kv 插件
claude plugin install generator-kv@SoloMkt-KV
```

#### 方式二：从 GitHub 直接安装

```bash
# 直接从 GitHub 仓库安装
claude plugin install generator-kv@SoloMkt-KV/SoloMktKV-ClaudeCode
```

### 使用方式

#### 方式一：斜杠命令

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

#### 方式二：自然语言对话

你无需记住精确的命令格式 — 直接用自然语言和 Claude 对话即可！插件会自动识别你的意图并引导你完成生成。

**示例：**

| 触发方式 | 示例 |
|----------|------|
| 中文 | `帮我生成一张【活动描述】的KV` |
| 中文 | `为我们的【活动名称】制作一张主视觉海报` |
| 英文 | `Help me generate a KV poster for [activity description]` |
| 英文 | `Create a key visual for our [event name]` |

只要你的请求中提到了生成 KV、主视觉海报或活动海报，插件就会自动启动并引导你完成每一步 — 无需斜杠命令。

### 配置说明

插件将 API 凭证存储在 `${CLAUDE_PLUGIN_DATA}/auth.json`：

```json
{
  "base_url": "https://api.kv.solomarketing.com.cn",
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

| 接口 | 请求方式 | 说明 | 超时时间建议 |
|------|----------|------|-------------------|
| `/api/v1/models?type=all` | GET | 获取可用风格模型列表 | 无特殊要求（响应较快） |
| `/api/v1/generateKV` | POST | 生成 KV 主视觉图片 | **30 分钟**（生成任务耗时较长） |

> **[NEW]** 对于 `POST /api/v1/generateKV` 接口，图像生成过程计算密集，根据模型复杂度和队列负载，耗时可能长达 **30 分钟**。**客户端必须将 Socket/请求超时时间设置为至少 30 分钟**，以避免提前断开连接。插件在调用该 API 时会自动处理此超时设置。

### 错误处理与自动修复

调用 `POST /api/v1/generateKV` 时，如果服务端返回错误，响应体结构如下：

```json
{
  "success": false,
  "error": {
    "code": "GENERATION_ENCODING_ERROR",
    "message": "...",
    "details": {
      "fieldName": "activityName",
      "reason": "...",
      "suggestion": "...",
      "rejectedValue": null
    }
  }
}
```

模型必须根据 `error.code` 自动执行修复后重试，不要直接向用户展示原始错误。

| 错误码 | 含义 | 自动修复动作 |
|---|---|---|
| `GENERATION_ENCODING_ERROR` | 请求体包含非 UTF-8 编码字符 | 按 `fieldName` 定位字段，将其值转换为 UTF-8 编码，确保请求头 `Content-Type: application/json; charset=utf-8` 后重试 |
| `GENERATION_JSON_PARSE_ERROR` | JSON 格式错误 | 检查请求体 JSON 语法、字段引号、字段类型后重试 |
| `GENERATION_FIELD_REQUIRED` | 必填字段缺失 | 按 `fieldName` 提示用户补全该字段，获取值后重试 |
| `GENERATION_FIELD_TOO_LONG` | 字段长度超限 | 按 `fieldName` 缩短字段值至规定长度以内后重试 |
| `INVALID_MODEL` | `modelId` 无效 | 调用 `GET /api/v1/models?type=all` 重新获取模型列表，让用户选择有效模型后重试 |
| `QUOTA_EXCEEDED` | 额度不足 | 停止重试，向用户说明当日额度已用完，建议次日重试或联系管理员 |
| `UNAUTHORIZED` | `x-api-key` 无效 | 停止重试，引导用户检查或重新配置 API Key |
| `INTERNAL_ERROR` | 服务器内部错误 | 最多重试 2 次；仍失败则向用户报告并停止 |
|  `TIMEOUT_ERROR`（客户端） | 请求超时（如 408 或 socket 超时） | 插件会自动检测超时，若服务端未返回明确失败信息，则**重试一次**；若第二次仍超时，告知用户建议稍后重试或联系支持 |

自动修复原则：
- 优先读取 `error.details.suggestion`，按其指引执行。
- 修复后必须重新调用 `POST /api/v1/generateKV`，并保持 `x-api-key` 不变。
- 不要修改 `x-api-key` 和其他有效字段。
- 如果连续 2 次自动修复仍失败，停止重试并清晰告知用户。
- 对于超时错误，插件不会反复重试（最多额外尝试一次），以避免服务器过载。

### 仓库信息

- **GitHub 仓库**: [https://github.com/SoloMkt-KV/SoloMktKV-ClaudeCode](https://github.com/SoloMkt-KV/SoloMktKV-ClaudeCode)
- **插件市场名称**: SoloMkt-KV
- **插件名称**: generator-kv
- **作者**: [SoloMkt-KV](https://github.com/SoloMkt-KV)

### 开源协议

MIT License — 详见 [LICENSE](LICENSE) 文件。

---

如果需要进一步调整（比如将超时时间改为可配置项），请告诉我，我可以继续优化。
