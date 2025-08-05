# ojs-docker

This repo is meant for local testing/debugging/development of the DHIL's install of OJS and should roughly reflect the version and infrastructure used in production. It is not meant for direct usage in any production environment.

The config is based on the [OJS DockerHub docs](https://hub.docker.com/r/pkpofficial/ojs) and the [pkp containers](https://github.com/pkp/containers) repo for the latest stable version (currently stable-3_5_0)

The goal is to generate a single OJS instance per journal so that each hosted journal is not dependent on other journal deps (plugins/themes) so they can be upgrades and managed separately

## Initial Setup

Add j1.localhost to your hosts file
```bash
sudo nano /etc/hosts
#add the following to the end of the file
127.0.0.1 j1.localhost
```

Setup initial persistence files (config.inc.php and plugin directory)

```bash
# create persistence dir
mkdir -p .data/app

# get the `config.inc.php` from `config.TEMPLATE.inc.php` and copy over the plugin directory as starting base
docker create --name=ojs_config_temp --platform=linux/amd64 pkpofficial/ojs:3_5_0-1
docker cp ojs_config_temp:/var/www/html/config.TEMPLATE.inc.php .data/app/config.inc.php
docker rm ojs_config_temp

# update the `config.inc.php` with mailhog settings
sed -i '' -e "s/default = sendmail/default = smtp/g" .data/app/config.inc.php
sed -i '' -e "s/sendmail_path =/; sendmail_path =/g" .data/app/config.inc.php
sed -i '' -e "s/; smtp = On/smtp = On/g" .data/app/config.inc.php
sed -i '' -e "s/; smtp_server = .*/smtp_server = mail/g" .data/app/config.inc.php
sed -i '' -e "s/; smtp_port = 25/smtp_port = 8025/g" .data/app/config.inc.php

# update the `config.inc.php` with some config secrets
sed -i '' -e "s/^salt = .*$/salt = \"$(openssl rand -hex 48 | tr -d '\n')\"/g" .data/app/config.inc.php
sed -i '' -e "s/^api_key_secret = .*$/api_key_secret = \"$(openssl rand -hex 48 | tr -d '\n')\"/g" .data/app/config.inc.php
sed -i '' -e "s/require_validation = Off/require_validation = On/g" .data/app/config.inc.php
```

Now startup the OJS container for the first time along with init the journal `Journal 1`

```bash
docker compose up -d --build
# wait a few seconds for the server to fully startup

# basic site install
BASE_URL=http://j1.localhost:8080 DOMAIN=j1.localhost DATABASE_HOST=db DATABASE_USER=ojs DATABASE_NAME=ojs DATABASE_PASSWORD=password ADMIN_EMAIL=dhil@sfu.ca ADMIN_PASSWORD=password scripts/cli-install-site.sh

# journal install + some misc (turn off admin notifications)
BASE_URL=http://j1.localhost:8080 JOURNAL_ACRONYM=j1 JOURNAL_NAME="Journal 1" SITE_TITLE="Test OJS Instance" CONTACT_NAME="OJS Administrator" CONTACT_EMAIL=dhil@sfu.ca ADMIN_PASSWORD=password scripts/cli-install-journal.sh

# fix base url
docker exec -e BASE_URL=http://j1.localhost:8080 ojs_app /usr/local/bin/cli-fix-config-base-url

# populate default users and journal content
docker exec ojs_app php tools/importExport.php UserImportExportPlugin import /demo-data/users.xml j1
docker exec ojs_app php tools/importExport.php NativeImportExportPlugin import /demo-data/issue.xml j1 admin
```
>Note: this uses a custom install scripts (this a above and beyond the the standard bin `pkp-cli-install` script)

Then visit `http://j1.localhost:8080`

## Startup

    docker compose up -d --build

## Shutdown

    docker compose down

## Upgrade

    docker exec -it ojs_app /usr/local/bin/ojs-upgrade

# Adding new plugins/themes

>Warning: Never add a theme/plugin via the UI (it will not persist when container is restarted). You can explore them but you should do the following to add it to the container.

You can also override default plugins/themes by using the same plugin/theme name when doing the following

## Add customized themes/plugins

Add new `<NAME>` theme/plugin dir into to the `themes`/`plugins` folders (don't compress them).

Fix potential permission issues
```bash
sudo chmod -R 775 plugins themes
sudo chown -R 33:33 plugins themes
```

## Add external (non-customized) themes/plugins

Add new `<NAME>-<VERSION>.tar.gz` themes/plugins to the `themes`/`plugins` dir (leave it `tar.gz`)
Update the `Dockerfile` adding `plugins/<NAME>-<VERSION>.tar.gz`/`themes/<NAME>-<VERSION>.tar.gz` to the list in the proper `ADD` steps near the end.
