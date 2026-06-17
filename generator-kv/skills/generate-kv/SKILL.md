---
name: generate-kv
description: Generate activity KV key visual posters. Use when the user invokes /generate-kv, asks to "generate KV", "create KV poster", "make activity poster", "generate key visual", "生成KV", "生成主视觉", "制作活动海报".
argument-hint: <activity_name>
allowed-tools: [Bash, Read, Write, AskUserQuestion]
---

# Generator-KV — Activity KV Key Visual Poster Generation

This skill guides the user through generating an activity KV (Key Visual) poster using the SoloMktKV API.

## Configuration

The plugin stores API credentials in `${CLAUDE_PLUGIN_DATA}/auth.json` with the following structure:

```json
{
  "base_url": "https://solosmart-uat.issmart.com.cn",
  "x-api-key": "generated-api-key",
  "created_at": "2026-04-10T00:00:00.000Z",
  "source": "auto_provisioned"
}
```

## Flow

### Step 0: Read the activity name from arguments

The user may provide an activity name via `$ARGUMENTS`. If provided, store it as the preliminary `activityName` for later use. If not provided, proceed without it.

### Step 1: Check API Key Configuration

Read the auth file at `${CLAUDE_PLUGIN_DATA}/auth.json` using the Read tool.

**If the file does not exist or `x-api-key` is empty/missing:**

1. Inform the user: "⚠️ SoloMktKV API Key is not configured. This key is required to call the model list and KV generation APIs."
2. Ask the user to provide their API Key (`x-api-key` value). Also optionally ask if they want to customize the `base_url` (default: `https://solosmart-uat.issmart.com.cn`).
3. Once the user provides the key, create/update `${CLAUDE_PLUGIN_DATA}/auth.json` with:

```json
{
  "base_url": "<base_url_or_default>",
  "x-api-key": "<user_provided_key>",
  "created_at": "<current_ISO_timestamp>",
  "source": "auto_provisioned"
}
```

Use the Write tool to save this file. Make sure the directory exists first (run `mkdir -p` via Bash if needed).

4. Confirm: "✅ API Key configured successfully!"

**If the file exists and `x-api-key` is valid:**

Proceed directly to Step 2.

### Step 2: Fetch Model List

Use `curl` via Bash to fetch the available models:

```bash
AUTH_FILE="${CLAUDE_PLUGIN_DATA}/auth.json"
BASE_URL=$(jq -r '.base_url' "$AUTH_FILE")
API_KEY=$(jq -r '.["x-api-key"]' "$AUTH_FILE")
curl -s -X GET "${BASE_URL}/solomkt_kv/api/v1/models?type=all" -H "x-api-key: ${API_KEY}"
```

Parse the JSON response. If `success` is not `true`, report the error to the user and stop.

Otherwise, extract the `data.system[]` array. Each model has:
- `id` — Model ID (use this for generation)
- `name` — Display name (e.g., "科技蓝调")
- `sub` — Sub-style (e.g., "极简主义")
- `tags` — Style tags
- `gradient` — CSS gradient preview
- `previewImageUrl` — Preview image URL

### Step 3: Let User Select a Model

Present the available models to the user using **AskUserQuestion**. Format each option as:

```
label: "<id> - <name> (<sub>)"
description: "Tags: <tags>"
```

If there are more than 4 models, display them all in a readable list first, then ask the user to type the model ID they want. Use AskUserQuestion with the top models and an "Other" option for the rest.

The user must select one model. Store the selected `id` as `modelId`.

### Step 4: Collect Required Activity Information

Use **AskUserQuestion** to collect the remaining required fields from the user. Ask all questions at once:

1. **activityName** (Activity Name / 活动名称): 1-200 characters, required. If `$ARGUMENTS` was provided, pre-fill with that value but still allow the user to edit.
2. **activityTheme** (Activity Theme / 活动主题): 1-200 characters, required.
3. **activityTime** (Activity Time / 活动时间): 1-200 characters, required. E.g., "2026年6月22日—26日"
4. **activityLocation** (Activity Location / 活动地点): 1-200 characters, required. E.g., "中国国际展览中心（顺义馆）"

After getting the required info, optionally ask:

5. **prompt** (Supplementary prompt / 补充提示词): Optional, max 1000 characters. Additional generation requirements.
6. **posterQuality** (Image Quality / 图片质量): Optional. Options: "2K" (default), "4K", "HD"
7. **posterSize** (Image Size / 图片尺寸): Optional. Options: "16:9" (default, horizontal), "9:16" (vertical), "1:1" (square), "4:3", "3:4"

### Step 5: Call the Generate KV API

Construct and send the POST request:

```bash
AUTH_FILE="${CLAUDE_PLUGIN_DATA}/auth.json"
BASE_URL=$(jq -r '.base_url' "$AUTH_FILE")
API_KEY=$(jq -r '.["x-api-key"]' "$AUTH_FILE")

# Build JSON payload using jq for proper escaping
jq -n \
  --arg modelId "<modelId>" \
  --arg activityName "<activityName>" \
  --arg activityTheme "<activityTheme>" \
  --arg activityTime "<activityTime>" \
  --arg activityLocation "<activityLocation>" \
  --arg prompt "<prompt_or_empty>" \
  --arg posterQuality "<posterQuality_or_2K>" \
  --arg posterSize '<posterSize_json_array>' \
  '{
    modelId: $modelId,
    activityName: $activityName,
    activityTheme: $activityTheme,
    activityTime: $activityTime,
    activityLocation: $activityLocation,
    prompt: $prompt,
    posterQuality: $posterQuality,
    posterSize: $posterSize
  }' > /tmp/generate_kv_payload.json

curl -s -X POST "${BASE_URL}/solomkt_kv/api/v1/generatekV" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d @/tmp/generate_kv_payload.json
```

Important: The `posterSize` parameter must be passed as a JSON string representation of an array, e.g., `'["16:9"]'` (a string that looks like a JSON array, not an actual JSON array). In jq, use `--arg posterSize '["16:9"]'` to pass it as a string.

### Step 6: Present Results

Parse the API response. On success, it returns an array of image URLs:

```json
[
  "https://files-dev.renmaibaohe.com/2026/06/20260608091909-8061c148.png",
  "https://files-dev.renmaibaohe.com/2026/06/20260608091913-58db4bb7.png"
]
```

Display the results to the user:
1. Show each generated image URL
2. If the platform supports it, render the images inline
3. Provide a summary of the generation parameters used

If the API returns an error, display the error message and suggest the user verify their parameters and API key.

## Important Notes

- **API Key Security**: The API key is stored locally in `${CLAUDE_PLUGIN_DATA}/auth.json` and is never transmitted except to the configured SoloMktKV API server.
- **Default base URL**: `https://solosmart-uat.issmart.com.cn` (API paths are under `/solomkt_kv/api/v1/`)
- **posterSize format**: Always pass as a string representation of a JSON array, e.g., `'["16:9"]'` not `["16:9"]`.
- All text fields (activityName, activityTheme, activityTime, activityLocation) are limited to 200 characters.
- The prompt field is optional and limited to 1000 characters.
- The generated images are hosted on the remote server. Download them if long-term storage is needed.
