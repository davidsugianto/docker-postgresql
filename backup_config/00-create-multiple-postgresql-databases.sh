#!/bin/bash

set -e
set -u

function create_database() {
	local database=$1
	echo "  Creating database '$database'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRESQL_USERNAME" <<-EOSQL
	    CREATE DATABASE $database;
EOSQL
}

function create_user_previledges() {
	echo "creating database and set user permissions previledges"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRESQL_USERNAME" <<-EOSQL
		REVOKE CREATE ON SCHEMA public FROM PUBLIC;
		REVOKE ALL ON DATABASE $POSTGRES_DB_1, $POSTGRES_DB_2 FROM PUBLIC;
		CREATE ROLE readwrite;
		GRANT CONNECT ON DATABASE $POSTGRES_DB_1, $POSTGRES_DB_2 TO readwrite;
		GRANT USAGE, CREATE ON SCHEMA public TO readwrite;
		GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO readwrite;
		ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite;
		GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO readwrite;
		ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO readwrite;
		CREATE USER $PG_USER WITH PASSWORD '$PG_PASSWORD';
		GRANT readwrite TO $PG_USER;

EOSQL
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
	echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
	for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
		create_database $db
	done
	echo "Multiple databases created"
fi

# Call command issued to the docker service
exec "$@"
