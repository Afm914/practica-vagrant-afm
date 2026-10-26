#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "########################################"
echo "Aprovisionando WWW"
echo "########################################"

# 1. Actualización
apt-get update -y

# 2. Nginx, OpenSSL y PHP
apt-get install -y nginx openssl php-fpm php-opcache php-gd php-mysql php-curl
PHPV=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

# 3. Certificado autofirmado
mkdir -p /etc/ssl/private /etc/ssl/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt \
  -subj "/C=ES/ST=Almeria/L=Almeria/O=IES_CELIA_VINAS/OU=IT/CN=localhost"

# 4. Sitio web en Nginx
rm -f /etc/nginx/sites-enabled/default
cat <<'NGINX' > /etc/nginx/sites-available/servidor_web
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name localhost;
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    root /var/www/html;
    index index.php index.html;
    location / {
        try_files $uri $uri/ =404;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }
}
NGINX
ln -sf /etc/nginx/sites-available/servidor_web /etc/nginx/sites-enabled/servidor_web

# 5. Limitar procesos PHP para no agotar la RAM
sed -i 's/^pm.max_children = .*/pm.max_children = 3/' /etc/php/$PHPV/fpm/pool.d/www.conf

# 6. Página de prueba
rm -f /var/www/html/index.nginx-debian.html
cat > /var/www/html/index.php << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Servidor WWW - DMZ</title>
</head>
<body>
    <h1>¡Hola! Estás en el servidor WWW</h1>
    <p>Dirección IP del servidor: <?php echo $_SERVER['SERVER_ADDR']; ?></p>
    <p><a href="info.php">Ver PHP Info</a></p>
</body>
</html>
HTML
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
chown -R www-data:www-data /var/www/html

# 7. Arrancar servicios
nginx -t
systemctl enable php$PHPV-fpm nginx
systemctl restart php$PHPV-fpm nginx

echo "=> Blindando acceso SSH en www..."
id admin_alex >/dev/null 2>&1 || useradd -m -s /bin/bash admin_alex
usermod -aG sudo admin_alex

mkdir -p /home/admin_alex/.ssh
sed 's/\r$//' /tmp/id_ed25519.pub > /home/admin_alex/.ssh/authorized_keys
chown -R admin_alex:admin_alex /home/admin_alex/.ssh
chmod 700 /home/admin_alex/.ssh
chmod 600 /home/admin_alex/.ssh/authorized_keys

cat <<'EOF' > /etc/ssh/sshd_config.d/00-bastionado.conf
PermitRootLogin no
PasswordAuthentication no
EOF

sshd -t
systemctl restart ssh

# Evitar que dhcpcd meta rutas por defecto en eth0
grep -q '^interface eth0' /etc/dhcpcd.conf || cat >> /etc/dhcpcd.conf <<'EOF'
interface eth0
nogateway
EOF

echo "------ FIN ------"