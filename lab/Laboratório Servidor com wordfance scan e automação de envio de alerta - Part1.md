## Introdução ao Laboratório

O laboratório teve como foco a criação de um servidor web com **Ubuntu Server 24.04 (live-server)** para hospedagem do **WordPress**. Após a configuração, foi simulada uma infecção por **PHP Injection**, com o desafio de desenvolver uma automação que integre o **Wordfence Scan** a uma rotina de **monitoramento e alerta de ameaças**.

A máquina virtual utilizada para este ambiente foi configurada com os seguintes recursos:

- **Tipo:** Ubuntu Server 24.04
- **Memória RAM:** 2048 MB
- **Disco:** 16 GB
- **Processador:** 1 núcleo
- **Placa de rede:** Modo _Bridge_ (permitindo acesso direto à rede local)

---

## Preparação do Ambiente

Antes da instalação do WordPress, foi necessário preparar o servidor com os componentes essenciais de um ambiente LAMP (Linux, Apache, MySQL, PHP). Os primeiros comandos executados foram:

```bash
sudo apt update && sudo apt upgrade -y
```

Em seguida, instalou-se o servidor web Apache, o banco de dados MySQL e o interpretador PHP:

```bash
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql -y
```

---

## Instalação do WordPress

Para garantir segurança e controle, o WordPress foi baixado e descompactado no diretório `/tmp`, que é temporário por padrão no Linux — uma prática útil para evitar acúmulo de arquivos em caso de falhas:

```bash
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress /var/www/html/
```

Após a movimentação dos arquivos, foram ajustadas as permissões para que o servidor Apache possa acessá-los corretamente:

```bash
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress
```

---

## Configuração do Banco de Dados

Foi criado um banco de dados específico para o WordPress, junto com um usuário dedicado:

```sql
sudo mysql
CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## Configuração do Apache

Para que o Apache reconheça o WordPress como site principal, foi criado um arquivo de configuração personalizado:

```bash
sudo nano /etc/apache2/sites-available/wordpress.conf
```

Conteúdo do arquivo:

```apache
<VirtualHost *:80>
    ServerAdmin admin@192.168.100.69
    DocumentRoot /var/www/html/wordpress
    ServerName 192.168.100.69

    <Directory /var/www/html/wordpress>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

---

## Ativação do Site

Após a configuração, o site foi ativado e o Apache reiniciado:

```bash
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
```

---

## Teste de Acesso

Com tudo configurado, o WordPress pôde ser acessado via navegador pelo IP da máquina:

```
http://192.168.100.69/
```

A partir daí, foi possível seguir com a instalação gráfica do WordPress, definindo título do site, usuário administrador, senha e e-mail.
