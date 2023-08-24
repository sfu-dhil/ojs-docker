# ojs-docker

This repo is meant for local testing/debugging/development of the DHIL's install of OJS and should roughly reflect the version and infrastructure used in production. It is not meant for direct usage in any production environment.

The config is based on the https://gitlab.com/pkp-org/docker/ojs output for latest stable version OJS on alpine apache (currently stable-3_4_0)

## Initial Setup

Comment out the following lines in `docker-compose.yaml`
- `- .data/app/config.inc.php:/var/www/html/config.inc.php`
- `- .data/app/plugins:/var/www/html/plugins`

    docker compose up -d

Visit `http://localhost:8080` and fill in the install page with the follows (leave unmentioned fields as is):

    Username: admin
    Password: password
    Repeat password: password
    Email: admin@admin.com

    Time zone: Vancouver (-07:00)

    Host: db
    Username: ojs
    Password: password
    Database name: ojs

    OAI Settings Repository Identifier: localhost:8080

Then click 'Install Open Journal Systems'

Once install is done:

    mkdir -p .data/app
    docker cp ojs_app:/var/www/html/config.inc.php .data/app/config.inc.php
    docker cp -a ojs_app:/var/www/html/plugins .data/app/plugins

    docker compose down

Uncomment out the following lines in `docker-compose.yaml`
- `- .data/app/config.inc.php:/var/www/html/config.inc.php`
- `- .data/app/plugins:/var/www/html/plugins`

Fill in following the remaining config settings

    sed -i '' -e "s/default = sendmail/default = smtp/g" .data/app/config.inc.php
    sed -i '' -e "s/sendmail_path =/; sendmail_path =/g" .data/app/config.inc.php
    sed -i '' -e "s/; smtp = On/smtp = On/g" .data/app/config.inc.php
    sed -i '' -e "s/; smtp_server = mail.example.com/smtp_server = mail/g" .data/app/config.inc.php
    sed -i '' -e "s/; smtp_port = 25/smtp_port = 8025/g" .data/app/config.inc.php

Startup the server again

    docker compose up -d

## Startup

    docker compose up -d

## Shutdown

    docker compose down

## Upgrade

    docker exec -it ojs_app /usr/local/bin/ojs-upgrade
