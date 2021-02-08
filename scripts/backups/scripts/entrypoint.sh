#!/bin/sh
# -----------------------------------------------------------------------------
#  Setting up the PostgreSQL Database backups
# -----------------------------------------------------------------------------
#  Author     : David Sugianto
#  Repository : https://github.com/davidsugianto
#  License    : GNU General Public License v3.0
# -----------------------------------------------------------------------------

print_line() {
	echo "-----------------------------------------------------------------------------"
}

get_time() {
	DATE=$(date '+%Y-%m-%d %H:%M:%S')
	echo ${DATE}
}

setup_pgpass() {
    echo "Setting up the pgpass conf"
    tee ~/.pgpass << EOF
${POSTGRESQL_HOST}:${POSTGRESQL_PORT}:${POSTGRESQL_STAGING_DATABASE}:${POSTGRESQL_USER}:${POSTGRESQL_PASSWORD}
${POSTGRESQL_HOST}:${POSTGRESQL_PORT}:${POSTGRESQL_PRODUCTION_DATABASE}:${POSTGRESQL_USER}:${POSTGRESQL_PASSWORD}
EOF
    chmod 0600 ~/.pgpass
    export PGPASSFILE='~/.pgpass'
    echo "Successfully setup pgpass conf"
}

setup_cronjob() {
    echo "Setting up the postgresql backups cronjob"
    touch /var/log/db_dump/db_staging_cron.log
    touch /var/log/db_dump/db_production_cron.log
    crontab -l > backupcron

    echo "0 0 * * * /scripts/backup-staging.sh >> /var/log/db_dump/db_staging_cron.log" >> backupcron
    echo "5 0 * * * /scripts/backup-production.sh >> /var/log/db_dump/db_production_cron.log" >> backupcron

    crontab backupcron
    echo "Cron job Database Backup is Completed"

    service cron start

    echo "** Starting CronJob **"
    echo "Successfuly setting up the postgresql backups cronjob"
    tail -f /var/log/db_dump/db_production_cron.log
}

main() {
    print_line
    get_time
	setup_pgpass
    setup_cronjob
}

main $@
