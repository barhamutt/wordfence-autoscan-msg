# 🔐 Wordfence CLI Scan Automation + Email & Discord Notification

![Wordfence](image/wordfence.png)

Este script realiza varreduras de segurança em instalações WordPress usando o **Wordfence CLI**, envia relatórios por **e-mail** e também notifica via **Discord webhook**. Ideal para administradores que desejam monitorar a integridade de seus sites automaticamente.

---

## 🧠 O que esse script faz?

- Executa uma varredura de malware com o Wordfence CLI.
- Gera um relatório com os principais alertas e arquivos suspeitos.
- Envia esse relatório por e-mail.
- Notifica via Discord (se o relatório tiver até 2000 caracteres).
- Registra logs locais para auditoria.

---

## ⚙️ Configurações Básicas

Você pode configurar os seguintes parâmetros diretamente no script ou via arquivo `.env`:

| Variável          | Descrição                                   |
| ----------------- | ------------------------------------------- |
| `WP_PATH`         | Caminho da instalação do WordPress          |
| `EMAIL_TO`        | Email(s) que receberão o relatório          |
| `LOG_FILE`        | Caminho do arquivo de log                   |
| `CONFIG_FILE`     | Caminho do arquivo `.ini` do Wordfence CLI  |
| `DISCORD_WEBHOOK` | URL do webhook do Discord para notificações |

Exemplo de `.env`:

```dotenv
WP_PATH="/var/www/wordpress"
EMAIL_TO="seuemail@email.com"
LOG_FILE="$HOME/.log/wordfence_scan.log"
CONFIG_FILE="/home/administrador/.config/wordfence/wordfence-cli.ini"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/ID/AQUI"
```

---

# 🛠️ Guia de Implementação do Script Wordfence

### 1. 📁 Preparando o Ambiente

Antes de tudo, verifique se os seguintes requisitos estão atendidos:

- Wordfence CLI instalado (`wordfence.deb`)
- Arquivo Wordpress posicionado corretamente (`wordpress`)
  de preferencia em `/var/www/aquivo_aqui`
-  Ferramentas: `jq`, `curl`, `mail`
- WordPress instalado no caminho correto
- Configuração do Wordfence em `/home/administrador/.config/wordfence/wordfence-cli.ini`
- Crie um webhook no canal desejado no Discord >> Copie a URL do webhook.

Instale dependências:

```bash
sudo apt update
sudo apt install jq curl mailutils
```

Permissão de execução no script:

  ```bash
  chmod +x ~/wordfence_scan.sh
  ```

### 2. 🕒 Agendar Execução Semanal com Cron

Você pode configurar o `cron` para rodar o script **duas vezes por semana**, por exemplo, **segunda e quinta às 2h da manhã**.

1. Edite o crontab:
   ```bash
   crontab -e
   ```

2. Adicione esta linha:
   ```bash
   0 2 * * 1,4 ~/wordfence_scan.sh
   ```

🔎 Explicação:
- `0 2`: às 02:00
- `* *`: qualquer dia e mês
- `1,4`: segunda (1) e quinta (4)

### 3. 🧪 Executar Teste Manual

Quando quiser executar uma varredura de teste com saída no terminal:

```bash
./wordfence_scan.sh --teste
```

Isso roda o scan, imprime informações no terminal, e também registra no log e envia o e-mail conforme o script.

### 4. 📄 Verificando Logs

Após cada execução, o log estará disponível em:

```bash
cat /var/log/wordfence_scan.log
```

Você pode acompanhar alertas e identificar arquivos suspeitos diretamente por ali.

---

# Observação :

## 📪 Casos em que o E-mail não chega ou fica preso...

#### 🧪 1. Teste básico com remetente definido

Tenta rodar isso:

```bash
echo "Teste manual do sistema de email" | mail -s "Teste Wordfence" -r administrador@localhost seuemail@email.com
```

Isso força o remetente como `administrador@localhost`, que às vezes é necessário pra não ser rejeitado pelo servidor de destino.

### 📨 2. Verifique fila de emails locais

Seu sistema pode estar tentando enviar, mas os emails estão presos. Veja:

```bash
mailq
```

Se aparecer uma fila, o problema pode ser na entrega (falta de DNS reverso, rejeição do email, etc.)

## 🚫 Por que o E-Mail não responde?

A  maioria dos provedores modernos **bloqueia conexões diretas por segurança**. Se seu servidor não tiver:

- IP fixo com reputação confiável
- DNS reverso (PTR record) configurado
- SPF, DKIM e DMARC válidos

... ele vai dar time-out toda vez 

## 💡 Solução: usar SMTP autenticado

### ➤ `msmtp` + Gmail, Outlook ou outro servidor SMTP

Com ele, seu script manda e-mail autenticado, usando um servidor de verdade — sem depender de porta 25 bloqueada.

Pode configurar isso pra você com:

- Gmail 
- Outlook
- Servidores SMTP 

## 🛠️ Passo a passo para configurar `msmtp` com Gmail (ou outro SMTP)

### 1. 📦 Instalar o `msmtp` e o agente de envio

```bash
sudo apt update
sudo apt install msmtp msmtp-mta
```

### 2. 🗂️ Criar arquivo de configuração personalizado

Crie o arquivo `~/.msmtprc`:

```bash
nano ~/.msmtprc
```

E cole algo como isso para Gmail:

```ini
# Arquivo de configuração do msmtp
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log

account        email
host           smtp.email.com
port           587
from           seuemail@email.com
user           seuemail@email.com
password       sua_senha_de_aplicativo
account default : email
```

> 💡 **Importante:** Para Gmail, você precisa gerar uma **senha de aplicativo** em [https://myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords). Isso funciona mesmo se a verificação em duas etapas estiver ativada.

📧 Se for usar gmail, Outlook, Yahoo, ou servidor da empresa mude o template...

### 3. 🔐 Ajustar permissões

O arquivo deve ser acessível apenas por você:

```bash
chmod 600 ~/.msmtprc
```

### 4. 🧪 Testar envio manual

```bash
echo "Testando envio via msmtp" | msmtp seuemail@hotmail.com
```

## 🔁 Integrar ao seu script

Basta substituir o trecho do `mail` por:

```bash
echo "$EMAIL_BODY" | iconv -f utf-8 -t utf-8 | msmtp "$EMAIL_TO"
```

---

## 📬 Exemplo de Notificação (Email ou Discord)

```text
RELATÓRIO WORDFENCE
────────────────────────────────────

Data: 2025-07-16
Caminho: /var/www/wordpress
Status: AVISO

────────────────────────────────────

Resumo do Scan:
WARNING: Plugin 'xyz' desatualizado
INFO: Nenhum malware encontrado
...

────────────────────────────────────

Arquivos suspeitos detectados:
/var/www/wordpress/wp-content/xyz.php
Obfuscated code detected
...
```

---

## 🧠 Observações Finais

- 🛡️ Ideal para monitorar sites WordPress com segurança em segundo plano
- 🎯 Pode ser adaptado para escanear múltiplas instalações WordPress
- 💬 Discord é perfeito para integrar com canais de sysadmin ou DevOps

