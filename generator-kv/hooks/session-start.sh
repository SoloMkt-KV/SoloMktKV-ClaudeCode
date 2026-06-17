#!/usr/bin/env bash
#
# Generator-KV Session Start Hook
# Checks whether the SoloMktKV API Key has been configured.
# If not configured, reminds the user to run /generate-kv to set it up.
#

set -euo pipefail

AUTH_FILE="${CLAUDE_PLUGIN_DATA}/auth.json"

STATUS="not_configured"
API_KEY_EXISTS="false"

if [[ -f "$AUTH_FILE" ]]; then
  # Check if x-api-key field exists and is non-empty
  API_KEY=$(jq -r '.["x-api-key"] // ""' "$AUTH_FILE" 2>/dev/null || echo "")
  if [[ -n "$API_KEY" ]] && [[ "$API_KEY" != "null" ]]; then
    STATUS="configured"
    API_KEY_EXISTS="true"
    BASE_URL=$(jq -r '.base_url // "https://solosmart-uat.issmart.com.cn"' "$AUTH_FILE" 2>/dev/null || echo "https://solosmart-uat.issmart.com.cn")
    CREATED_AT=$(jq -r '.created_at // ""' "$AUTH_FILE" 2>/dev/null || echo "")
    SOURCE=$(jq -r '.source // "manual"' "$AUTH_FILE" 2>/dev/null || echo "manual")

    # Mask API key for display (show first 4 and last 4 chars)
    KEY_LEN=${#API_KEY}
    if [[ $KEY_LEN -gt 8 ]]; then
      MASKED_KEY="${API_KEY:0:4}****${API_KEY: -4}"
    else
      MASKED_KEY="****"
    fi

    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Generator-KV plugin status: API Key configured (${MASKED_KEY}) | Base URL: ${BASE_URL} | Created: ${CREATED_AT} | Source: ${SOURCE}.\\nUse /generate-kv <activity_name> to generate a KV poster."
  }
}
EOF
    exit 0
  fi
fi

# Not configured — remind the user
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "⚙️  Generator-KV plugin: API Key is NOT yet configured. Run /generate-kv to set up your API Key and start generating KV posters. Or provide your API Key now and Claude will auto-configure it for you."
  }
}
EOF

exit 0
