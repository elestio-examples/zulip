set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 150s;

docker-compose exec -T zulip su zulip -c "/home/zulip/deployments/current/manage.py create_realm zulip ${ADMIN_EMAIL} ${ADMIN_EMAIL} --password ${ADMIN_PASSWORD}"