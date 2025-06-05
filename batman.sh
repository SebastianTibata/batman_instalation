#!/bin/bash

# CONFIGURACIÓN
NODE_IP="10.0.0.1"             
WIFI_IFACE="wlo1"               # ip link show
ESSID="batnet"
ADHOC_BSSID="02:12:34:56:78:9A"
CHANNEL="1"

sudo apt update
sudo apt install -y kmod iw wireless-tools batctl

# Verificar si la interfaz existe
if ! ip link show "$WIFI_IFACE" &> /dev/null; then
  echo "❌ Interfaz '$WIFI_IFACE' no encontrada. Revisa con 'ip link show'"
  exit 1
fi

echo "Configurando interfaz"
sudo ip link set "$WIFI_IFACE" down
sudo iwconfig "$WIFI_IFACE" mode ad-hoc
sudo iwconfig "$WIFI_IFACE" essid "$ESSID"
sudo iwconfig "$WIFI_IFACE" ap "$ADHOC_BSSID"
sudo iwconfig "$WIFI_IFACE" channel "$CHANNEL"
sudo ip link set "$WIFI_IFACE" up

echo "Cargando módulo batman-adv"
sudo modprobe batman-adv

echo "Configurando interfaz bat0"
sudo ip link add name bat0 type batadv 2>/dev/null
sudo ip link set bat0 up
sudo batctl if add "$WIFI_IFACE"
sudo ip link set "$WIFI_IFACE" up

echo "Asignando IP $NODE_IP a bat0"
sudo ip addr add "$NODE_IP/24" dev bat0

echo "Configuración completada en $(hostname)"
echo "Usa 'batctl n' para ver vecinos, 'batctl o' para tabla de rutas"
