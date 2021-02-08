#!/bin/sh

/usr/bin/pg_dump -U $POSTGRESQL_USER -h $POSTGRESQL_HOST -p $POSTGRESQL_PORT -Fc $POSTGRESQL_STAGING_DATABASE > /backups/staging/$POSTGRESQL_STAGING_DATABASE-$(date +\%A).sql
echo "$(date +%Y/%m/%d-%H:%M:%S): Successfully dump of $POSTGRESQL_STAGING_DATABASE-$(date +%A%d%m%Y) database from $POSTGRESQL_HOST"

# Call command issued to the docker service
exec "$@"
