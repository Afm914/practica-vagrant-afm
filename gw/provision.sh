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
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 172.1.3.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.2.3.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.3.3.0/24 -o eth0 -j MASQUERADE
echo "Gateway configurado"