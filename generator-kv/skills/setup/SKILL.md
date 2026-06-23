---
name: setup
description: Guide users through installing the Generator-KV plugin, configuring their API Key, verifying the setup, and showing usage examples. Use when the user asks to "install KV plugin", "setup KV", "configure KV poster", "安装KV插件", "配置KV", "初始化KV", "how to use KV plugin", or provides this file directly.
allowed-tools: [Bash, Read, Write, AskUserQuestion]
---

# Generator-KV Plugin �?Installation & Setup Guide

This skill walks the user through the complete setup of the Generator-KV plugin: installation, API Key configuration, verification, and usage instructions.

## Step 1: Check Current State

First, check if the plugin is already installed:

```bash
claude plugin list 2>/dev/null || echo "not_installed"
```

Also check if the marketplace is already added:

```bash
claude plugin marketplace list 2>/dev/null || echo "no_marketplaces"
```

## Step 2: Install the Plugin

If the plugin is not installed, guide the user through installation.

### Option A: Install from Marketplace (Recommended)

```bash
# 1. Add the SoloMkt-KV marketplace
claude plugin marketplace add SoloMkt-KV/SoloMktKV-ClaudeCode

# 2. Install the generator-kv plugin from the marketplace
claude plugin install generator-kv@SoloMkt-KV
```

### Option B: Install from GitHub Directly

```bash
claude plugin install generator-kv@SoloMkt-KV/SoloMktKV-ClaudeCode
```

After installation, tell the user: *"�?插件安装成功！接下来配置 API Key 即可开始使用�?* (or *"�?Plugin installed! Next, let's configure your API Key."*)

## Step 3: Configure API Key

Ask the user for their API credentials using `AskUserQuestion`:

```
questions: [
  {
    question: "请提供你�?SoloMktKV API Key（x-api-key）：",
    header: "API Key",
    options: [
      { label: "手动输入", description: "输入你从管理员处获取�?x-api-key" }
    ]
  },
  {
    question: "API 服务器地址（可选，默认使用预配环境）：",
    header: "Base URL",
    options: [
      { label: "使用默认", description: "https://api.kv.solomarketing.com.cn" },
      { label: "自定义地址", description: "输入自定义的 API 服务�?URL" }
    ]
  }
]
```

Once the user provides the API Key (and optional base URL), save it:

```bash
mkdir -p "${CLAUDE_PLUGIN_DATA}"

# Use the provided values, defaulting base_url if not customized
jq -n \
  --arg key "<user_provided_api_key>" \
  --arg url "<user_provided_or_default_base_url>" \
  '{
    "base_url": $url,
    "x-api-key": $key,
    "created_at": (now | strftime("%Y-%m-%dT%H:%M:%S.000Z")),
    "source": "guided_setup"
  }' > "${CLAUDE_PLUGIN_DATA}/auth.json"
```

After saving, tell the user: *"�?API Key 已安全保存到本地�?*

## Step 4: Verify the Setup

Test the API Key by fetching the available models:

```bash
AUTH_FILE="${CLAUDE_PLUGIN_DATA}/auth.json"
BASE_URL=$(jq -r '.base_url' "$AUTH_FILE")
API_KEY=$(jq -r '.["x-api-key"]' "$AUTH_FILE")

curl -s -X GET "${BASE_URL}/api/v1/models?type=all" \
  -H "x-api-key: ${API_KEY}" \
  --max-time 30
```

### On Success

If the API returns a valid model list, tell the user:

> �?**配置验证成功！Generator-KV 插件已就绪�?*
>
> **验证结果�?* API Key 有效，成功获取到 X 个风格模型�?

### On Failure

If the API returns an error, tell the user:

> ⚠️ **API Key 验证失败�?* 请检查：
> 1. API Key 是否正确（注意大小写和空格）
> 2. 网络是否能访�?`{BASE_URL}`
> 3. 是否已联系管理员获取有效�?API Key
>
> 你可以重新运�?`/generate-kv` 来更新配置�?

## Step 5: Explain How to Use

Once everything is verified, present the usage guide. **Default to natural language conversation** �?no slash command needed.

---

## 🎉 使用指南 | Usage Guide

### 方式一：自然语言对话（推荐）�?

直接用自然语言描述你的需求，插件会自动识别并引导你完成每一步：

| 语言 | 示例 |
|------|------|
| 🇨🇳 中文 | `帮我生成一张【新品发布会】的KV` |
| 🇨🇳 中文 | `为我们的�?18大促】制作一张主视觉海报` |
| 🇨🇳 中文 | `做一个【年会盛典】的KV海报` |
| 🇨🇳 中文 | `帮我生成一张推广活动的KV` |
| 🇬🇧 English | `Help me generate a KV poster for our product launch` |
| 🇬🇧 English | `Create a key visual for our summer sale event` |
| 🇬🇧 English | `Make an activity poster for our annual gala` |

**触发关键词：** 只要你的请求中提�?生成KV"�?主视觉海�?�?活动海报"�?KV poster"�?key visual"等，插件就会自动启动�?

### 方式二：斜杠命令

如果你喜欢精确命令：

```
/generator-kv:generate-kv <活动名称>
```

**示例�?*
```
/generator-kv:generate-kv 第四届中国国际供应链促进博览�?
```

---

## 🔄 生成流程

无论使用哪种方式，插件都会按照以下流程引导你�?

1. 🔑 **检查配�?* �?自动验证 API Key 状�?
2. 🎨 **选择风格** �?浏览可选视觉风格模型并选择
3. 📝 **填写活动信息** �?活动名称、主题、时间、地�?
4. ⚙️ **可选设�?* �?补充提示词、图片质量（2K/4K）、尺寸比�?
5. 🖼�?**生成海报** �?调用 API 生成（预�?1�? 分钟�?
6. 📎 **返回结果** �?展示生成�?KV 海报图片链接

---

## 💡 小贴�?

- **API Key 只需配置一�?*，之后每次会话插件会自动加载
- 会话启动时会显示 API Key 状态，确保一切就�?
- 如需更换 API Key，重新运�?`/generate-kv` 即可覆盖旧配�?
- 所有凭证仅存储在本�?`${CLAUDE_PLUGIN_DATA}/auth.json`，不会上传到其他服务�?
