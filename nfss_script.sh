#!/bin/bash

set -e  # Останавливаем выполнение при ошибках

echo "Обновление системы и установка NFS-сервера..."
apt-get update && apt-get install -y nfs-kernel-server

# Создаем директорию для экспорта и устанавливаем необходимые права
SHARE_DIR="/srv/share"
UPLOAD_DIR="$SHARE_DIR/upload"

echo "Создание директорий $SHARE_DIR и $UPLOAD_DIR..."
mkdir -p "$UPLOAD_DIR"
chown -R nobody:nogroup "$SHARE_DIR"
chmod 0777 "$UPLOAD_DIR"

# Настраиваем экспорт директории
EXPORTS_FILE="/etc/exports"
CLIENT_IP="192.168.50.11/32"

echo "Настройка экспорта в $EXPORTS_FILE..."
echo "$SHARE_DIR $CLIENT_IP(rw,sync,root_squash)" > "$EXPORTS_FILE"

# Применяем изменения экспорта
echo "Применение экспорта..."
exportfs -ra

# Перезапускаем NFS-сервис
echo "Перезапуск NFS-сервера..."
systemctl restart nfs-kernel-server

echo "Настройка NFS-сервера завершена!"

