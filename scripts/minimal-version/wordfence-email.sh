#!/bin/bash
WP="/var/www/html/wordpress"
EMAIL="seuemail@email.com"
DATA=$(date '+%Y-%m-%d %H:%M')
RELATORIO=$(wordfence malware-scan "$WP" --include-all-files --verbose)
RELATORIO+="\n$(wordfence vuln-scan "$WP" --verbose)"
echo -e "$RELATORIO" | mail -s "[Wordfence] $DATA" "$EMAIL"