
### Implementação do script no sistema

Para garantir que o script de escaneamento funcionasse plenamente no servidor, foi necessário movê-lo para o diretório padrão de executáveis do sistema Linux, permitindo sua execução global a partir de qualquer local.

1. O procedimento foi realizado com os seguintes comandos:

```bash
sudo mv wordfence_scan.sh /usr/local/bin/wordfence-autoscan.sh
sudo chmod +x /usr/local/bin/wordfence-autoscan.sh
```

2. Com isso, o script passou a estar disponível como um comando direto no terminal:

```bash
wordfence-autoscan.sh
```

3. Além disso, o script pode ser facilmente editado a qualquer momento utilizando o editor `nano`:

```bash
sudo nano /usr/local/bin/wordfence-autoscan.sh
```

---

### Integração com Plataformas de Alerta

Para que o sistema de notificações funcione corretamente, é necessário configurar os seguintes recursos:

- **Webhook do Discord**: Crie um webhook no seu servidor para receber alertas em tempo real diretamente em um canal específico.
- **Bot no Telegram**: Configure um bot de aplicação e obtenha o token de acesso. Inclua o bot no algoritmo do script para envio de mensagens automáticas.

> Essas integrações permitem que o script envie alertas de segurança diretamente para seus canais de comunicação, garantindo monitoramento contínuo e resposta rápida a qualquer incidente.

---

### Automação com Cron Job

Com o serviço **cron** já ativo no servidor, foi realizado o agendamento do script de escaneamento para execução automática em horários definidos.

 1. foi aberto o agendador de tarefas para o usuário atual:

```bash
crontab -e
```

Ao executar esse comando pela primeira vez, o sistema solicita a escolha de um editor de texto. Recomenda-se selecionar a opção **1 (nano)** por ser mais simples e intuitiva.

2. Dentro do arquivo de agendamento, foi adicionada a seguinte linha:

```cron
0 3 * * * /usr/local/bin/wordfence-autoscan.sh
```

> Essa configuração agenda a execução automática do script todos os dias às **03:00 da manhã**, garantindo que os escaneamentos sejam realizados regularmente e os alertas enviados conforme necessário.

---

Com essa etapa, o sistema de monitoramento de segurança do WordPress está completamente automatizado, integrado e funcional, oferecendo uma solução robusta e eficiente para ambientes que exigem vigilância contínua contra ameaças e vulnerabilidades.
