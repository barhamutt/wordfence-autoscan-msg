Para garantir a segurança do ambiente WordPress, foi realizada a instalação do **Wordfence CLI**, ferramenta de linha de comando voltada para escaneamento de malwares e vulnerabilidades. Além disso, foi configurado o serviço **cron**, responsável por automatizar tarefas recorrentes no servidor.

---

### Instalação do Wordfence CLI (.deb)

O Wordfence foi instalado diretamente via pacote `.deb`, utilizando os comandos abaixo:

```bash
cd /tmp
wget https://github.com/wordfence/wordfence-cli/releases/latest/download/wordfence.deb
sudo apt install ./wordfence.deb
```

Após a instalação, foi possível verificar a versão instalada com:

```bash
wordfence --version
```

#### Primeiros testes de segurança

Com o Wordfence instalado, foram realizados os primeiros escaneamentos:

- **Malware Scan:**

  ```bash
  wordfence malware-scan /var/www/html/wordpress --include-all-files --verbose
  ```

- **Vulnerability Scan:**

  ```bash
  wordfence vuln-scan /var/www/html/wordpress --verbose
  ```

Esses comandos analisam todos os arquivos do WordPress e exibem detalhes sobre possíveis ameaças ou falhas de segurança.

---

### Instalação e configuração do `Cron`

Para automatizar os escaneamentos, foi instalado e ativado o serviço **cron**, responsável por agendar tarefas no sistema:

```bash
sudo apt install cron
sudo systemctl start cron
sudo systemctl enable cron
```

A verificação do status do serviço foi feita com:

```bash
sudo systemctl status cron
```

Com o cron ativo, é possível agendar rotinas de escaneamento e alertas automáticos, garantindo monitoramento contínuo do ambiente WordPress.

---

### Integração para Email

#### Instalação de utilitário `mail` 

Para dar ao servidor o acesso a serviços de smtp, foi instalado e ativado o serviço mail:

```bash
sudo apt install mailutils
```

Durante a instalação, será solicitado que você configure o **Postfix**, que é o agente responsável por enviar os e-mails. Se o objetivo for apenas enviar mensagens simples localmente ou via relay externo (como Gmail ou Hotmail), selecione a opção **"Internet Site"** e siga com a instalação padrão.

#### Hotmail

No caso do Hotmail, nenhuma configuração adicional é necessária — o envio funciona direto com o `mail`.

#### Gmail

Para o Gmail, é necessário realizar algumas configurações extras, pois o Google exige autenticação segura para aceitar e-mails de servidores externos. Aqui estão os passos que foram seguidos:

1. **Criação de Senha de Aplicativo**  
    Acesse sua conta Google e gere uma [senha de app](https://myaccount.google.com/apppasswords) (requer autenticação em dois fatores ativada).
    
2. **Configuração do Relay SMTP no Postfix**  
    Edite o arquivo de configuração principal do Postfix:
```bash
sudo nano /etc/postfix/main.cf
```
    
3. Adicione ou ajuste as seguintes linhas:
```ini
relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
```
    
4. **Criação do arquivo de autenticação**  
    Crie o arquivo com suas credenciais:
```bash
sudo nano /etc/postfix/sasl_passwd
```
    
Conteúdo:
```
[smtp.gmail.com]:587 EMAIL@gmail.com:SENHA_DE_APP
```
    
Em seguida, proteja e compile o arquivo:
```bash
sudo postmap /etc/postfix/sasl_passwd
sudo chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
sudo chmod 600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
```
    
5. **Reinicie o Postfix**  
    Para aplicar as mudanças:
```bash
sudo systemctl restart postfix
```
    
6. **Teste de envio**  
```bash
echo "Teste de envio via Gmail" | mail -s "Assunto do Teste" EMAIL@gmail.com
```


>Para uso correto do Gmail, é **obrigatório** gerar uma **senha de aplicativo**. Essa chave permite que o servidor envie mensagens de forma legítima e segura.