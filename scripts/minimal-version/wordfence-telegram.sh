#!/bin/bash
WP="/var/www/html/wordpress"
TOKEN="TOKEN"
CHAT="CHAT_ID"
DATA=$(date '+%Y-%m-%d %H:%M')
RELATORIO="[$DATA] $(wordfence malware-scan "$WP" --include-all-files --verbose)
$(wordfence vuln-scan "$WP" --verbose)"
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
  -d chat_id="$CHAT" --data-urlencode "text=$RELATORIO"