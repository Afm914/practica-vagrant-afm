#!/usr/bin/env bash

# El script se detiene si hay errores
set -e
export DEBIAN_FRONTEND=noninteractive
echo "########################################"
echo " Aprovisionando Gateway "
echo "########################################"
echo "-----------------"
echo "Actualizando repositorios"
apt-get update -y && apt-get autoremove -y
apt-get install -y net-tools iputils-ping curl tcpdump nmap
echo "Cortafuegos basico"
# Respondemos de antemano a iptables-persistent para que no se pare la instalación
echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
apt-get install -y iptables-persistent
# Enrutamiento persistente en Debian 13
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-enrutamiento.conf
sysctl -p /etc/sysctl.d/99-enrutamiento.conf
# Limpieza y NAT (cambia el 99 por tu número de clase N)
iptables -F
iptables -t nat -F
iptables -t nat -A POSTROUTING -s 172.1.3.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.2.3.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.3.3.0/24 -o eth0 -j MASQUERADE
# Guardar reglas persistentes
netfilter-persistent save