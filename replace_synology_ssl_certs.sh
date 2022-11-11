#!/bin/sh

# Script start. Запускаем продление сертификата
docker-compose  -f /volume2/docker/certbot/cloudflare/docker-compose.yml up
# Копируем сертификаты и применяем в DSM 7.1*

REVERSE_PROXY=/usr/syno/etc/certificate/ReverseProxy
FQDN_DIR=/usr/syno/etc/certificate/system/FQDN
DEFAULT_DIR=
DEFAULT_DIR_NAME=$(cat /usr/syno/etc/certificate/_archive/DEFAULT)
if [ "DEFAULT_DIR_NAME" != "" ]; then
	DEFAULT_DIR="/usr/syno/etc/certificate/_archive/${DEFAULT_DIR_NAME}"
fi

# Move certs from /tmp to install directory
cp --remove-destination /volume2/docker/certbot/cloudflare/cert/live/lipadmin.ru/{privkey,fullchain,cert}.pem /usr/syno/etc/certificate/system/default/
if [ "$?" != 0 ]; then
	echo "Halting because of error moving files"
	exit 1
fi

# Ensure correct permissions
chown root:root /usr/syno/etc/certificate/system/default/{privkey,fullchain,cert}.pem
if [ "$?" != 0 ]; then
	echo "Halting because of error chowning files"
	exit 1
fi
echo "Certs moved from /tmp & chowned."

# If you're using a custom domain name, replace the FQDN certs too
if [ -d "${FQDN_DIR}/" ]; then
    echo "Found FQDN directory, copying certificates to 'certificate/system/FQDN' as well..."
    cp /usr/syno/etc/certificate/system/default/{privkey,fullchain,cert}.pem "${FQDN_DIR}/"
    chown root:root "${FQDN_DIR}/"{privkey,fullchain,cert}.pem
fi

# Replace certs for default Application Portal (if found)
if [ -d "$DEFAULT_DIR" ]; then
	echo "Found upload dir (used for Application Portal): $DEFAULT_DIR_NAME, copying certs to: $DEFAULT_DIR"
    cp /usr/syno/etc/certificate/system/default/{privkey,fullchain,cert}.pem "$DEFAULT_DIR/"
    chown root:root "$DEFAULT_DIR/"{privkey,fullchain,cert}.pem
else
	echo "Did not find upload dir (Application Portal): $DEFAULT_DIR_NAME"
fi

# Replace certs for all reverse proxy servers (if exists)
if [ -d "$REVERSE_PROXY" ]; then
        echo "Found reverse proxy certs, replacing those:"
        for proxy in $(ls "$REVERSE_PROXY"); do
		echo "Replacing $REVERSE_PROXY/$proxy"
		cp /usr/syno/etc/certificate/system/default/{privkey,fullchain,cert}.pem "$REVERSE_PROXY/$proxy"
		chown root:root "$REVERSE_PROXY/$proxy/"{privkey,fullchain,cert}.pem
	done
else
	echo "No reverse proxy directory found"
fi

# Reboot synology services
echo -n "Rebooting all the things..."
systemctl restart nginx
systemctl restart avahi
echo " done"
