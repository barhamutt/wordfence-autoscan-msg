#!/bin/bash
WP="/var/www/html/wordpress"
HOOK="https://discord.com/api/webhooks/ID/TOKEN"
DATA=$(date '+%Y-%m-%d %H:%M')
RELATORIO="[$DATA] $(wordfence malware-scan "$WP" --include-all-files --verbose)
$(wordfence vuln-scan "$WP" --verbose)"
curl -H "Content-Type: application/json" -X POST \
  -d "$(jq -n --arg msg "$RELATORIO" '{content:$msg}')" "$HOOK"