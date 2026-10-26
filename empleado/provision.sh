#!/usr/bin/env bash
# El script se detiene si hay errores
set -e
export DEBIAN_FRONTEND=noninteractive
echo "########################################"
echo "Aprovisionando cliente "
echo "########################################"
echo "-----------------"
echo "Actualizando repositorios"
apt-get update -y
apt-get install -y curl nmap tcpdump wget iputils-ping
# Evitar que dhcpcd meta rutas por defecto en eth0
grep -q '^interface eth0' /etc/dhcpcd.conf || cat >> /etc/dhcpcd.conf <<'EOF'
interface eth0
nogateway
EOF
echo "------ FIN ------"