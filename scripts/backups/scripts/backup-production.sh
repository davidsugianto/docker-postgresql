#!/bin/sh

pg_dump -U $POSTGRESQL_USER -h $POSTGRESQL_HOST -p $POSTGRESQL_PORT -Fc $POSTGRESQL_PRODUCTION_DATABASE > /backups/production/$POSTGRESQL_PRODUCTION_DATABASE-$(date +\%A).sql
echo "$POSTGRESQL_PRODUCTION_DATABASE-$(date +%A%d%m%Y)"

# Call command issued to the docker service
exec "$@"
