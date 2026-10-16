#!/bin/sh

# El script se detiene si hay errores
set -e
echo "########################################"
echo " Aprovisionando adminpc "
echo "########################################"
echo "-----------------"
echo "Actualizando repositorios"
apk update
apk add nano curl nmap tcpdump wget bash iputils sudo

echo "=> Creando usuario administrador..."
adduser -D admin_alex
adduser admin_alex wheel
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

echo "=> Importando claves SSH desde el anfitrión..."
mkdir -p /home/admin_alex/.ssh
mv /tmp/id_ed25519 /home/admin_alex/.ssh/id_ed25519
mv /tmp/id_ed25519.pub /home/admin_alex/.ssh/id_ed25519.pub
sed -i 's/\r$//' /home/admin_alex/.ssh/id_ed25519

chown -R admin_alex:admin_alex /home/admin_alex/.ssh
chmod 700 /home/admin_alex/.ssh
chmod 600 /home/admin_alex/.ssh/id_ed25519
chmod 644 /home/admin_alex/.ssh/id_ed25519.pub

echo "------ FIN ------"