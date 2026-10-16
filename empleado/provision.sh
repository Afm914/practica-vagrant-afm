#!/bin/sh

# El script se detiene si hay errores
set -e
export DEBIAN_FRONTEND=noninteractive
echo "########################################"
echo " Aprovisionando cliente "
echo "########################################"
echo "-----------------"
echo "Actualizando repositorios"
apt-get update -y
apt-get install -y curl nmap tcpdump wget bash iputils-ping
echo "------ FIN ------"