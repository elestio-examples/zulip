#set env vars
set -o allexport; source .env; set +o allexport;

# apt install jq -y

mkdir -p ./postgresql/data
chown -R 1000:1000 ./postgresql/data

mkdir -p ./rabbitmq
chown -R 1000:1000 ./rabbitmq

mkdir -p ./redis
chown -R 1000:1000 ./redis

mkdir -p ./zulip
chown -R 1000:1000 ./zulip