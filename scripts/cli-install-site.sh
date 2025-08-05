#!/bin/sh

echo "[CLI Install Site] First time running this container, preparing..."
echo "[CLI Install Site] Calling the install using pre-defined variables..."
curl -o /dev/null --silent --show-error --fail -L -X POST "$BASE_URL/index/en/install/install" \
    -d installLanguage="en" \
    -d installing="0" \
    -d adminUsername="admin" \
    -d adminPassword="$ADMIN_PASSWORD" \
    -d adminPassword2="$ADMIN_PASSWORD" \
    -d adminEmail="$ADMIN_EMAIL" \
    -d locale="en" \
    -d timeZone="America/Vancouver" \
    -d filesDir="/var/www/files" \
    -d databaseDriver="postgres9" \
    -d databaseHost="$DATABASE_HOST" \
    -d databaseUsername="$DATABASE_USER" \
    -d databasePassword="$DATABASE_PASSWORD" \
    -d databaseName="$DATABASE_NAME" \
    -d oaiRepositoryId="$DOMAIN"

echo "[CLI Install Site] DONE!"