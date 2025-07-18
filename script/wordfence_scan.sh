#!/bin/bash

# ────────────────[ CONFIGURAÇÕES BÁSICAS ]────────────────
WP_PATH="/var/www/wordpress"  # Caminho da instalação WordPress
EMAIL_TO="seuemail@email.com"  # Email de destino para o relatório
LOG_FILE="$HOME/.log/wordfence_scan.log"  # Caminho do arquivo de log
CONFIG_FILE="/home/administrador/.config/wordfence/wordfence-cli.ini"  # Arquivo de config do Wordfence
DATA="$(date +'%Y-%m-%d %H:%M')"  # Data formatada para exibição
DISCORD_WEBHOOK="https://discord.com/api/webhooks/ID/AQUI" # URL do webhook do Discord

# ────────────────[ FUNÇÃO DE LOG ]────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ────────────────[ FORMATA RELATÓRIO PADRÃO ]────────────────
# Essa função gera um texto formatado com os dados do scan
# Pode ser reutilizada tanto no email quanto na notificação do Discord
format_report() {
    cat <<EOF
RELATÓRIO WORDFENCE
────────────────────────────────────
Data: $(date)
Caminho: $WP_PATH
Status: $STATUS

────────────────────────────────────
Resumo do Scan:
$(echo "$SCAN_RESULT" | grep -E "INFO|WARNING|ERROR" | head -n 10)

────────────────────────────────────
Arquivos suspeitos detectados:
$(echo "$SCAN_RESULT" | grep -E "Obfuscated|$WP_PATH" | head -n 10)
EOF
}

# ────────────────[ ENVIA NOTIFICAÇÃO PARA DISCORD ]────────────────
# Essa versão escapa aspas e barras para evitar erro JSON no Discord
send_discord_notification() {
    local MESSAGE="$1"
    PAYLOAD=$(jq -n --arg msg "$MESSAGE" '{content: $msg}')
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "$PAYLOAD" \
         "$DISCORD_WEBHOOK"
}

# ────────────────[ PREPARA AMBIENTE DE EXECUÇÃO ]────────────────
prepare() {
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"

    # Verifica se o comando wordfence está disponível
    if ! command -v wordfence >/dev/null; then
        log "ERROR: wordfence não encontrado"
        echo "ERROR: Instale com: sudo dpkg -i wordfence.deb"
        exit 1
    fi

    # Verifica se o arquivo de configuração existe
    if ! [ -f "$CONFIG_FILE" ]; then
        log "ERROR: Arquivo de configuração não encontrado: $CONFIG_FILE"
        exit 2
    fi
}

# ────────────────[ EXECUTA VARREDURA COM WORDFENCE ]────────────────
run_scan() {
    log "Iniciando varredura Wordfence..."
    SCAN_RESULT=$(wordfence malware-scan "$WP_PATH" --config "$CONFIG_FILE" 2>&1)
    SCAN_EXIT=$?

    # Determina o status baseado no código de saída
    case $SCAN_EXIT in
        0) STATUS="SUCESSO" ;;
        1) STATUS="AVISO" ;;
        *) STATUS="ERRO" ;;
    esac

    log "Status: $STATUS - Código de saída: $SCAN_EXIT"
    log "Resultado da varredura: $SCAN_RESULT"

    EMAIL_SUBJECT="[$STATUS] Relatorio Wordfence - $DATA"

    # ─── Envia relatório por Email ───
    if command -v mail >/dev/null; then
        echo "$(format_report)" | iconv -f utf-8 -t utf-8 | mail -s "$EMAIL_SUBJECT" "$EMAIL_TO"
        log "Email enviado para: $EMAIL_TO"
    else
        log "Comando 'mail' não disponível"
    fi

    # ─── Teste de tamanho + Envio para Discord ───
    DISCORD_MESSAGE="**$(format_report)**"
    MESSAGE_SIZE=$(echo "$DISCORD_MESSAGE" | wc -c)
    log "Tamanho da mensagem formatada para Discord: $MESSAGE_SIZE"

    if [ "$MESSAGE_SIZE" -le 2000 ]; then
        send_discord_notification "$DISCORD_MESSAGE"
        log "Relatório enviado para Discord (${MESSAGE_SIZE} caracteres)."
    else
        log "Mensagem ultrapassou o limite de 2000 caracteres. Não foi enviada ao Discord."
    fi
}

# ────────────────[ EXECUÇÃO PRINCIPAL ]────────────────
prepare

if [ "$1" = "--teste" ]; then
    echo "=== MODO DE TESTE ==="
    echo "WordPress path: $WP_PATH"
    echo "Log file: $LOG_FILE"
    run_scan
    echo "=== Teste executado. Email/Discord ativados. Verifique o log e caixa de entrada. ==="
else
    run_scan
fi


