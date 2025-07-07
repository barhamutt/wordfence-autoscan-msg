#!/bin/bash

# Configurações básicas
WP_PATH="/var/www/wordpress"
EMAIL_TO="seuemail@email.com"
LOG_FILE="/var/log/wordfence_scan.log"
EMAIL_SUBJECT="Relatorio Wordfence - $(date +'%Y-%m-%d %H:%M')"
CONFIG_FILE="/home/administrador/.config/wordfence/wordfence-cli.ini"

# Função de log
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Prepara ambiente
prepare() {
    sudo touch "$LOG_FILE"
    sudo chown "$(whoami)":"$(whoami)" "$LOG_FILE"

    if ! command -v wordfence >/dev/null 2>&1; then
        log "ERROR: wordfence não encontrado"
        echo "ERROR: Instale com: sudo dpkg -i wordfence.deb"
        exit 1
    fi
}

# Executa a varredura
run_scan() {
    log "Iniciando varredura Wordfence..."

    SCAN_RESULT=$(wordfence malware-scan "$WP_PATH" --config "$CONFIG_FILE" 2>&1)
    SCAN_EXIT=$?

    if [ "$SCAN_EXIT" -eq 0 ]; then
        STATUS="SUCESSO"
    elif [ "$SCAN_EXIT" -eq 1 ]; then
        STATUS="AVISO"
    else
        STATUS="ERRO"
    fi

    log "Status: $STATUS - Código de saída: $SCAN_EXIT"
    log "Resultado da varredura: $SCAN_RESULT"

    if command -v mail >/dev/null 2>&1; then
    EMAIL_BODY="
    RELATORIO WORDFENCE
    ────────────────────────────────────
    
    Data: $(date)
    Caminho: $WP_PATH
    Status: $STATUS

    ────────────────────────────────────
    Resumo do Scan:
    ────────────────────────────────────

    $(echo "$SCAN_RESULT" | grep -E "INFO|WARNING|ERROR")

    ────────────────────────────────────
    Arquivos suspeitos detectados:
    ────────────────────────────────────

    $(echo "$SCAN_RESULT" | grep -E "^/var/www/wordpress|Obfuscated")"

    echo "$EMAIL_BODY" | iconv -f utf-8 -t utf-8 | mail -s "$EMAIL_SUBJECT" $EMAIL_TO
    log "Email enviado para: $EMAIL_TO"
    else
    log "Comando 'mail' não disponível"
    fi

}

# Execução principal
prepare

if [ "$1" = "--teste" ]; then
    echo "=== MODO DE TESTE ==="
    echo "WordPress path: $WP_PATH"
    echo "Log file: $LOG_FILE"
    run_scan
    echo "=== Verifique email e log ==="
else
    run_scan
fi
