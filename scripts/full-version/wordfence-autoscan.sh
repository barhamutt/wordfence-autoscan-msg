#!/bin/bash
# ───────────────[ CONFIGURAÇÕES INICIAL ]────────────────
EMAIL_TO="seuemail@email.com"
DISCORD_WEBHOOK_ID="ID_AQUI"
DISCORD_WEBHOOK_TOKEN="TOKEN_AQUI"
TELEGRAM_CHAT_ID="ID_AQUI"
TELEGRAM_TOKEN="TOKEN_AQUI"
WP_PATH="/var/www/html/wordpress"
LOG_FILE="$HOME/.log/wordfence_scan.log"
DATA=$(date '+%Y-%m-%d %H:%M')
# ───────────────[ FUNÇÕES AUXILIARES ]────────────────
log() { echo "[$(date '+%F %T')] $1" >> "$LOG_FILE"; }
send_discord() { curl -H "Content-Type: application/json" -X POST \
  -d "$(jq -n --arg msg "$1" '{content:$msg}')" "https://canary.discord.com/api/webhooks/$DISCORD_WEBHOOK_ID/$DISCORD_WEBHOOK_TOKEN"; }
send_telegram() { curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  --data-urlencode "text=$1" >/dev/null
}
# ───────────────[ PREPARAÇÃO DO AMBIENTE ]────────────────
prepare() { mkdir -p "$(dirname "$LOG_FILE")"; touch "$LOG_FILE" 
command -v wordfence >/dev/null || { echo "Instale o Wordfence CLI"; exit 1; }; }
# ───────────────[ EXECUÇÃO DOS SCANS ]────────────────
run_scan() {
  log "Iniciando scans..."
  MALWARE=$(wordfence malware-scan "$WP_PATH" --include-all-files --verbose)
  VULN=$(wordfence vuln-scan "$WP_PATH" --verbose)
# ───────────────[ MONTAGEM DO RELATÓRIO ]────────────────
  RELATORIO="RELATÓRIO WORDFENCE
Data: $DATA
Caminho: $WP_PATH

Malware Scan:
$MALWARE

Vulnerability Scan:
$VULN
"
# ───────────────[ ENVIO DO RELATÓRIO ]────────────────
echo "$RELATORIO" | mail -s "[Wordfence] Relatório $DATA" "$EMAIL_TO"
[ ${#RELATORIO} -le 2000 ] && send_discord "$RELATORIO"
[ ${#RELATORIO} -le 4096 ] && send_telegram "$RELATORIO"
log "Relatório enviado."
}
# ───────────────[ EXECUÇÃO PRINCIPAL ]────────────────
prepare
run_scan