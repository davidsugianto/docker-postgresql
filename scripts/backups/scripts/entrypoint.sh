#!/bin/sh
tee ~/.pgpass << EOF
${POSTGRESQL_HOST}:${POSTGRESQL_PORT}:${POSTGRESQL_STAGING_DATABASE}:${POSTGRESQL_USER}:${POSTGRESQL_PASSWORD}
${POSTGRESQL_HOST}:${POSTGRESQL_PORT}:${POSTGRESQL_PRODUCTION_DATABASE}:${POSTGRESQL_USER}:${POSTGRESQL_PASSWORD}
EOF
chmod 0600 ~/.pgpass
export PGPASSFILE='~/.pgpass'

crontab -l > backupcron

echo "0 0 * * * /scripts/backup-staging.sh >> /var/log/cron.log" >> backupcron
echo "5 0 * * * /scripts/backup-production.sh >> /var/log/cron.log" >> backupcron

crontab backupcron
echo "Cron job Database Backup is Completed"

service cron start

echo "** Starting CronJob **"

touch /var/log/cron.log /var/log/cron.log

tail -f /var/log/cron.log

# Call command issued to the docker service
exec "$@"
