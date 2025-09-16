# 🛡️ Wordfence Scan Automático com Notificações

Este script Bash foi desenvolvido para reforçar a segurança de ambientes WordPress em servidores web. Utilizando o Wordfence CLI, ele realiza varreduras automatizadas em busca de vulnerabilidades. Ao final do processo, gera um relatório detalhado e envia notificações para os administradores via e-mail, Discord e Telegram.



## 📁 Estrutura do Projeto

O projeto está organizado da seguinte forma:
```
wordfence-autoscan-msg/                     
├── lab/                          
│   ├── Laboratório Servidor ... - Part1.md
│   ├── Laboratório Servidor ... - Part2.md
│   └── Laboratório Servidor ... - Part3.md
├── scripts/                      
│   ├── full-version/            
│   │   ├── wordfence-autoscan.sh
│   │   └── wordfence-autoscan.uml
│   └── minimal-version/        
│       ├── wordfence-discord.sh
│       ├── wordfence-email.sh
│       └── wordfence-telegram.sh
└── README.md
```



## ⚙️ Requisitos

- **Wordfence CLI** instalado e disponível no `PATH`
- **Ferramentas de sistema**:
    - `curl` - para chamadas HTTP (Discord e Telegram)
    - `jq` - para formatação JSON (Discord)
    - `mail`- para envio de e-mail via terminal 
    - `cron` - para execuções de rotina

>Se for utilizar o Gmail como servidor de saída, é necessário configurar o SMTP Relay no Postfix previamente.

>Exemplos e dicas de configuração estão disponíveis em wordfence-autoscan-msg/lab.



## 🚀 Como usar

1. Clone o script para seu servidor:

```bash
git clone git@github.com:barhamutt/wordfence-autoscan-msg.git
```

2. Mova o `script` para o diretorio `bin/` e atribua a ele permissões de execução:

```bash
sudo mv wordfence_autoscan.sh /usr/local/bin/wordfence_autoscan.sh
sudo chmod +x /usr/local/bin/wordfence_autoscan.sh
```  

>Com isso, o script passou a estar disponível como um comando direto no terminal

3. Edite as variáveis de configuração no início do script:

```bash
sudo nano /usr/local/bin/wordfence-autoscan.sh
```
```bash
EMAIL_TO="seuemail@email.com"
DISCORD_WEBHOOK_ID="ID_AQUI"
DISCORD_WEBHOOK_TOKEN="TOKEN_AQUI"
TELEGRAM_CHAT_ID="ID_AQUI"
TELEGRAM_TOKEN="TOKEN_AQUI"
WP_PATH="/var/www/html/wordpress"
```

4. Configure o agendamento da execução do `script` com o `cron job`:

```bash
crontab -e
```
```bash
0 3 * * * /usr/local/bin/wordfence-autoscan.sh
```
> Essa configuração agenda a execução automática do script todos os dias às **03:00 da manhã**, garantindo que os escaneamentos sejam realizados regularmente e os alertas enviados conforme necessário.



## 📂 Estrutura do Relatório

O relatório contém:

- Data e hora da execução
- Caminho escaneado
- Resultado da varredura de malware
- Resultado da varredura de vulnerabilidades



## 📝 Log

Os logs são salvos em:

```
~/.log/wordfence_scan.log
```



## 🧠 Observações Finais

- Pode ser ideal para monitorar sites WordPress com segurança em segundo plano
- Pode ser adaptado para escanear múltiplas instalações WordPress
- Discord é perfeito para integrar com canais de sysadmin ou DevOps
