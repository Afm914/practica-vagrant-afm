#!/bin/sh

# El script se detiene si hay errores
set -e
echo "########################################"
echo " Aprovisionando adminpc "
echo "########################################"
echo "-----------------"
echo "Actualizando repositorios"
apt-get update -y
apt-get install -y curl nmap tcpdump wget iputils-ping
# Usuario administrador (grupo "sudo" en Debian)
echo "=> Creamos usuario administrador..."
id admin_alex >/dev/null 2>&1 || useradd -m -s /bin/bash admin_alex
usermod -aG sudo admin_alex
echo "admin_alex ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/admin_alex
chmod 440 /etc/sudoers.d/admin_alex
# Claves SSH inyectadas por Vagrant en /tmp
echo "=> Importamos claves SSH"
mkdir -p /home/admin_alex/.ssh
cp /tmp/id_ed25519 /home/admin_alex/.ssh/id_ed25519
cp /tmp/id_ed25519.pub /home/admin_alex/.ssh/id_ed25519.pub
sed -i 's/\r$//' /home/admin_alex/.ssh/id_ed25519 /home/admin_alex/.ssh/id_ed25519.pub
#Ajustamos permisos de las claves SSH
chown -R admin_alex:admin_alex /home/admin_alex/.ssh
chmod 700 /home/admin_alex/.ssh
chmod 600 /home/admin_alex/.ssh/id_ed25519
chmod 644 /home/admin_alex/.ssh/id_ed25519.pub
# Evitar que dhcpcd meta rutas por defecto en eth0
grep -q '^interface eth0' /etc/dhcpcd.conf || cat >> /etc/dhcpcd.conf <<'EOF'
interface eth0
nogateway
EOF
echo "------ FIN ------"