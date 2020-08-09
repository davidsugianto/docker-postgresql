#!/bin/bash

set -e
set -u

# TYPE  DATABASE        USER            ADDRESS                 METHOD

tee /opt/bitnami/postgresql/conf/pg_hba.conf << EOF
host     all             	        all             		0.0.0.0/0               md5
host     all             	        all             		::1/128                 md5
local    all             	        all                     		                md5
host     replication     	        all             		0.0.0.0/0               md5
host	 postgres		 	        all			 			0.0.0.0/0				md5
host 	 all				        postgres				0.0.0.0/0				md5
host	 $POSTGRESQL_DB_STAGING	 	$POSTGRESQL_USERNAME    0.0.0.0/0				md5
host	 $POSTGRESQL_DB_PRODUCTION 	$POSTGRESQL_USERNAME	0.0.0.0/0				md5
EOF

function create_database() {
	local database=$1
	echo "  Creating user and database '$database'"
	PGPASSWORD=$POSTGRESQL_POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $POSTGRESQL_USERNAME;
EOSQL
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
	echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
	for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
		create_database $db
	done
	echo "Multiple databases created"
fi


# echo "Deleted schema public"
# 	PGPASSWORD=$POSTGRESQL_POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --username postgres $POSTGRESQL_DB_PRODUCTION <<-EOSQL
#     DROP SCHEMA public CASCADE;
# EOSQL

# echo "Restore Database"
# PGPASSWORD=$POSTGRESQL_POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --username postgres $POSTGRESQL_DB_PRODUCTION < /backups/db_production-20200504-145153.sql

# echo "Deleted schmea public_old"
# 	PGPASSWORD=$POSTGRESQL_POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --username postgres $POSTGRESQL_DB_PRODUCTION <<-EOSQL
#     DROP SCHEMA public_old CASCADE;
# EOSQL