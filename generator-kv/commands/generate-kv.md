---
description: Generate activity KV key visual posters via SoloMktKV API
argument-hint: <activity_name>
allowed-tools: [Bash, Read, Write, AskUserQuestion]
---

# /generate-kv — Activity KV Key Visual Poster Generation

Invoke the `generate-kv` skill to guide the user through generating an activity KV poster.

## Flow Summary

1. **Check API Key** — Verify or auto-configure `${CLAUDE_PLUGIN_DATA}/auth.json`
2. **Fetch Models** — GET `/solomkt_kv/api/v1/models?type=all`
3. **Select Model** — Let user pick from available style models
4. **Collect Info** — activityName, activityTheme, activityTime, activityLocation
5. **Generate** — POST `/solomkt_kv/api/v1/generatekV`
6. **Present Results** — Display generated image URLs

## Implementation

Refer to the detailed instructions in `skills/generate-kv/SKILL.md` for the complete step-by-step flow.

Execute each step sequentially:

### Step 0: Read arguments
`$ARGUMENTS` may contain a pre-filled activity name. Store it for later use.

### Step 1: Check API Key Configuration
Read `${CLAUDE_PLUGIN_DATA}/auth.json`.

**If missing or x-api-key is empty:**
- Tell user: "⚠️ SoloMktKV API Key is not configured."
- Ask user to provide their `x-api-key`. Optionally ask for custom `base_url` (default: `https://solosmart-uat.issmart.com.cn`).
- Write the auth file:
```json
{
  "base_url": "<base_url_or_default>",
  "x-api-key": "<user_provided_key>",
  "created_at": "<current_ISO_timestamp>",
  "source": "auto_provisioned"
}
```
- Ensure directory exists via `mkdir -p` first.
- Confirm: "✅ API Key configured successfully!"

**If file exists and valid:** Proceed to Step 2.

### Step 2: Fetch Model List
```bash
AUTH_FILE="${CLAUDE_PLUGIN_DATA}/auth.json"
BASE_URL=$(jq -r '.base_url' "$AUTH_FILE")
API_KEY=$(jq -r '.["x-api-key"]' "$AUTH_FILE")
curl -s -X GET "${BASE_URL}/solomkt_kv/api/v1/models?type=all" -H "x-api-key: ${API_KEY}"
```

Parse response. If `success` is not true, report error and stop. Extract `data.system[]` array (id, name, sub, tags, gradient, previewImageUrl).

### Step 3: Let User Select a Model
Present models via **AskUserQuestion**. Format: `"<id> - <name> (<sub>)"`, description: `"Tags: <tags>"`. Store selected `id` as `modelId`.

### Step 4: Collect Required Activity Information
Use **AskUserQuestion** (ask all at once):
1. **activityName** (活动名称): 1-200 chars, required. Pre-fill with `$ARGUMENTS` if provided.
2. **activityTheme** (活动主题): 1-200 chars, required.
3. **activityTime** (活动时间): 1-200 chars, required. E.g., "2026年6月22日—26日"
4. **activityLocation** (活动地点): 1-200 chars, required.

Then optionally ask:
5. **prompt** (补充提示词): Optional, max 1000 chars.
6. **posterQuality** (图片质量): Optional. Options: "2K" (default), "4K", "HD"
7. **posterSize** (图片尺寸): Optional. Options: "16:9" (default), "9:16", "1:1", "4:3", "3:4"

### Step 5: Call Generate KV API
```bash
AUTH_FILE="${CLAUDE_PLUGIN_DATA}/auth.json"
BASE_URL=$(jq -r '.base_url' "$AUTH_FILE")
API_KEY=$(jq -r '.["x-api-key"]' "$AUTH_FILE")

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

Important: `posterSize` must be a JSON string representation of an array, e.g., `'["16:9"]'`.

### Step 6: Present Results
Parse response — on success it's an array of image URLs. Display each URL and summarize generation parameters. On error, display the error message.

## Important Notes
- API Key stored locally in `${CLAUDE_PLUGIN_DATA}/auth.json`, only sent to the configured API server
- Default base URL: `https://solosmart-uat.issmart.com.cn`
- `posterSize` always as string: `'["16:9"]'` not `["16:9"]`
- Text fields limited to 200 chars (activityName/Theme/Time/Location)
- Prompt limited to 1000 chars
