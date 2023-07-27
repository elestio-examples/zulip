<a href="https://elest.io">
  <img src="https://elest.io/images/elestio.svg" alt="elest.io" width="150" height="75">
</a>

[![Discord](https://img.shields.io/static/v1.svg?logo=discord&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=Discord&message=community)](https://discord.gg/4T4JGaMYrD "Get instant assistance and engage in live discussions with both the community and team through our chat feature.")
[![Elestio examples](https://img.shields.io/static/v1.svg?logo=github&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=github&message=open%20source)](https://github.com/elestio-examples "Access the source code for all our repositories by viewing them.")
[![Blog](https://img.shields.io/static/v1.svg?color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=elest.io&message=Blog)](https://blog.elest.io "Latest news about elestio, open source software, and DevOps techniques.")

# Zulip, verified and packaged by Elestio

[Zulip](https://github.com/zulip/docker-zulip) combines the immediacy of real-time chat with an email threading model.
With Zulip, you can catch up on important conversations while ignoring irrelevant ones.

<img src="https://github.com/elestio-examples/zulip/raw/main/zulip.png" alt="zulip" width="800">

Deploy a <a target="_blank" href="https://elest.io/open-source/zulip">fully managed Zulip</a> on <a target="_blank" href="https://elest.io/">elest.io</a> if you want automated backups, reverse proxy with SSL termination, firewall, automated OS & Software updates, and a team of Linux experts and open source enthusiasts to ensure your services are always safe, and functional.

[![deploy](https://github.com/elestio-examples/zulip/raw/main/deploy-on-elestio.png)](https://dash.elest.io/deploy?source=cicd&social=dockerCompose&url=https://github.com/elestio-examples/zulip)

# Why use Elestio images?

- Elestio stays in sync with updates from the original source and quickly releases new versions of this image through our automated processes.
- Elestio images provide timely access to the most recent bug fixes and features.
- Our team performs quality control checks to ensure the products we release meet our high standards.

# Usage

## Git clone

You can deploy it easily with the following command:

    git clone https://github.com/elestio-examples/zulip.git

Copy the .env file from tests folder to the project directory

    cp ./tests/.env ./.env

Edit the .env file with your own values.

Create data folders with correct permissions

    mkdir -p ./postgresql/data
    chown -R 1000:1000 ./postgresql/data

    mkdir -p ./rabbitmq
    chown -R 1000:1000 ./rabbitmq

    mkdir -p ./redis
    chown -R 1000:1000 ./redis

    mkdir -p ./zulip
    chown -R 1000:1000 ./zulip

Run the project with the following command

    docker-compose up -d

You can access the Web UI at: `http://your-domain:8080`

## Docker-compose

Here are some example snippets to help you get started creating a container.

    version: "3.3"
    services:
        database:
            image: "zulip/zulip-postgresql:14"
            restart: always
            environment:
                POSTGRES_DB: "zulip"
                POSTGRES_USER: "zulip"
                # Note that you need to do a manual `ALTER ROLE` query if you
                # change this on a system after booting the postgres container
                # the first time on a host.  Instructions are available in README.md.
                POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
            volumes:
                - "./postgresql/data:/var/lib/postgresql/data:rw"
        memcached:
            image: "memcached:alpine"
            restart: always
            command:
                - "sh"
                - "-euc"
                - |
                    echo 'mech_list: plain' > "$$SASL_CONF_PATH"
                    echo "zulip@$$HOSTNAME:$$MEMCACHED_PASSWORD" > "$$MEMCACHED_SASL_PWDB"
                    echo "zulip@localhost:$$MEMCACHED_PASSWORD" >> "$$MEMCACHED_SASL_PWDB"
                    exec memcached -S
            environment:
                SASL_CONF_PATH: "/home/memcache/memcached.conf"
                MEMCACHED_SASL_PWDB: "/home/memcache/memcached-sasl-db"
                MEMCACHED_PASSWORD: ${MEMCACHED_PASSWORD}
        rabbitmq:
            image: "rabbitmq:3.11.16"
            restart: always
            environment:
                RABBITMQ_DEFAULT_USER: "zulip"
                RABBITMQ_DEFAULT_PASS: ${RABBITMQ_DEFAULT_PASS}
            volumes:
                - "./rabbitmq:/var/lib/rabbitmq:rw"
        redis:
            image: "redis:alpine"
            restart: always
            command:
                - "sh"
                - "-euc"
                - |
                    echo "requirepass '$$REDIS_PASSWORD'" > /etc/redis.conf
                    exec redis-server /etc/redis.conf
            environment:
                REDIS_PASSWORD: ${REDIS_PASSWORD}
            volumes:
                - "./redis:/data:rw"
        zulip:
            image: elestio4test/zulip:${SOFTWARE_VERSION_TAG}
            restart: always
            # build:
            #   context: .
            #   args:
            #     # Change these if you want to build zulip from a different repo/branch
            #     ZULIP_GIT_URL: https://github.com/zulip/zulip.git
            #     ZULIP_GIT_REF: "7.1"
            #     # Set this up if you plan to use your own CA certificate bundle for building
            #     # CUSTOM_CA_CERTIFICATES:
            ports:
                - "172.17.0.1:8088:80"
                # - "443:443"
            environment:
                DB_HOST: "database"
                DB_HOST_PORT: "5432"
                DB_USER: "zulip"
                DISABLE_HTTPS: "True"
                SSL_CERTIFICATE_GENERATION: "self-signed"
                SETTING_MEMCACHED_LOCATION: "memcached:11211"
                SETTING_RABBITMQ_HOST: "rabbitmq"
                SETTING_REDIS_HOST: "redis"
                SECRETS_email_password: ${ADMIN_PASSWORD}
                # These should match RABBITMQ_DEFAULT_PASS, POSTGRES_PASSWORD,
                # MEMCACHED_PASSWORD, and REDIS_PASSWORD above.
                SECRETS_rabbitmq_password: ${RABBITMQ_DEFAULT_PASS}
                SECRETS_postgres_password: ${POSTGRES_PASSWORD}
                SECRETS_memcached_password: ${MEMCACHED_PASSWORD}
                SECRETS_redis_password: ${REDIS_PASSWORD}
                SECRETS_secret_key: ${ADMIN_PASSWORD}
                SETTING_EXTERNAL_HOST: ${DOMAIN}
                SETTING_ZULIP_ADMINISTRATOR: ${ADMIN_EMAIL}
                SETTING_EMAIL_HOST: ${SMTP_HOST}
                SETTING_EMAIL_HOST_USER: ""
                SETTING_EMAIL_PORT: ${SMTP_PORT}
                # It seems that the email server needs to use ssl or tls and can't be used without it
                SETTING_EMAIL_USE_TLS: "False"
                SETTING_ADD_TOKENS_TO_NOREPLY_ADDRESS: "False"
                SETTING_NOREPLY_EMAIL_ADDRESS: ${SMTP_FROM_EMAIL}
                ZULIP_AUTH_BACKENDS: "EmailAuthBackend"
                # Uncomment this when configuring the mobile push notifications service
                # SETTING_PUSH_NOTIFICATION_BOUNCER_URL: 'https://push.zulipchat.com'
            volumes:
                - "./zulip:/data:rw"
            ulimits:
                nofile:
                    soft: 1000000
                    hard: 1048576

# Maintenance

## Logging

The Elestio Zulip Docker image sends the container logs to stdout. To view the logs, you can use the following command:

    docker-compose logs -f

To stop the stack you can use the following command:

    docker-compose down

## Backup and Restore with Docker Compose

To make backup and restore operations easier, we are using folder volume mounts. You can simply stop your stack with docker-compose down, then backup all the files and subfolders in the folder near the docker-compose.yml file.

Creating a ZIP Archive
For example, if you want to create a ZIP archive, navigate to the folder where you have your docker-compose.yml file and use this command:

    zip -r myarchive.zip .

Restoring from ZIP Archive
To restore from a ZIP archive, unzip the archive into the original folder using the following command:

    unzip myarchive.zip -d /path/to/original/folder

Starting Your Stack
Once your backup is complete, you can start your stack again with the following command:

    docker-compose up -d

That's it! With these simple steps, you can easily backup and restore your data volumes using Docker Compose.

# Links

- <a target="_blank" href="https://github.com/zulip/docker-zulip">Zulip Github repository</a>

- <a target="_blank" href="https://zulip.com/help/getting-started-with-zulip">Zulip documentation</a>

- <a target="_blank" href="https://github.com/elestio-examples/zulip">Elestio/Zulip Github repository</a>
