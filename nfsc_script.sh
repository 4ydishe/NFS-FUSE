#!/bin/bash

set -e  # Останавливаем выполнение при ошибках

echo "Обновление системы и установка NFS-клиента..."
apt-get update && apt-get install -y nfs-common

# Данные о сервере и точке монтирования
SERVER_IP="192.168.50.10"
REMOTE_DIR="$SERVER_IP:/srv/share/"
MOUNT_POINT="/mnt"
UPLOAD_DIR="$MOUNT_POINT/upload"

# Проверяем, существует ли точка монтирования
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Создание точки монтирования $MOUNT_POINT..."
    mkdir -p "$MOUNT_POINT"
fi

# Добавляем запись в /etc/fstab, если её ещё нет
FSTAB_FILE="/etc/fstab"
MOUNT_OPTIONS="nfs vers=3,noauto,x-systemd.automount 0 0"

if ! grep -qs "$REMOTE_DIR" "$FSTAB_FILE"; then
    echo "Добавление записи в $FSTAB_FILE..."
    echo "$REMOTE_DIR $MOUNT_POINT $MOUNT_OPTIONS" >> "$FSTAB_FILE"
else
    echo "Запись уже существует в $FSTAB_FILE, пропускаем..."
fi

# Применяем изменения
echo "Перезагрузка systemd и запуск монтирования..."
systemctl daemon-reload
systemctl restart remote-fs.target

# Создаем директорию upload в /mnt, если её нет
if [ ! -d "$UPLOAD_DIR" ]; then
    echo "Создание директории $UPLOAD_DIR..."
    mkdir -p "$UPLOAD_DIR"
fi

# Монтируем NFS-ресурс для проверки
echo "Монтирование NFS-директории..."
mount "$MOUNT_POINT"

echo "Настройка NFS-клиента завершена!"
