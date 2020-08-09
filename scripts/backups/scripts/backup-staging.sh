#!/bin/sh

pg_dump -U $POSTGRESQL_USER -h $POSTGRESQL_HOST -p $POSTGRESQL_PORT -Fc $POSTGRESQL_STAGING_DATABASE > /backups/staging/$POSTGRESQL_STAGING_DATABASE-$(date +\%A).sql
echo "$POSTGRESQL_STAGING_DATABASE-$(date +%A%d%m%Y)"

# Call command issued to the docker service
exec "$@"
