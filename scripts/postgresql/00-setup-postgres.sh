#!/bin/bash

set -e
set -u

# TYPE  DATABASE        USER            ADDRESS                 METHOD

tee /opt/bitnami/postgresql/conf/pg_hba.conf << EOF
host   all             	          all             		  0.0.0.0/0  md5
host   all             	          all             		  ::1/128    md5
local  all             	          all                       		   md5
host   replication     	          all             		  0.0.0.0/0  md5
host	 postgres		 	              all			 			        0.0.0.0/0	 md5
host 	 all				                postgres				      0.0.0.0/0	 md5
host	 $POSTGRESQL_DB_STAGING	 	  $POSTGRESQL_USERNAME  0.0.0.0/0	 md5
host	 $POSTGRESQL_DB_PRODUCTION 	$POSTGRESQL_USERNAME	0.0.0.0/0	 md5
EOF

function create_database() {
	local database=$1
	echo "  Creating user and database '$database'"
	PGPASSWORD=$POSTGRESQL_POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $POSTGRESQL_USERNAME;
EOSQL
}

function remove_public_schema() {
    echo "Deleted schema public ${POSTGRESQL_DB_PRODUCTION}"
    PGPASSWORD=$POSTGRESQL_POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --username postgres $POSTGRESQL_DB_PRODUCTION <<-EOSQL
     DROP SCHEMA public CASCADE;
EOSQL
    echo "Deleted schema public ${POSTGRESQL_DB_STAGING}"
    PGPASSWORD=$POSTGRESQL_POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --username postgres $POSTGRESQL_DB_STAGING <<-EOSQL
     DROP SCHEMA public CASCADE;
EOSQL
}

if [ -e "/home/postgres/staging/${POSTGRESQL_DB_STAGING}-$(date +\%A).sql" -a -e "/home/postgres/production/${POSTGRESQL_DB_PRODUCTION}-$(date +\%A).sql" ]; then
  echo "Database is ready to import"
  if [ -n "$POSTGRESQL_MULTIPLE_DATABASES" ]; then
    echo "Multiple database creation requested: $POSTGRESQL_MULTIPLE_DATABASES"
    for db in $(echo $POSTGRESQL_MULTIPLE_DATABASES | tr ',' ' '); do
      create_database $db
    done
    echo "database is created"
    remove_public_schema
    echo "Importing Database Staging"
    cd /home/postgres/staging
    PGPASSWORD=$POSTGRESQL_POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --username postgres $POSTGRESQL_DB_STAGING < ${POSTGRESQL_DB_STAGING}-$(date +\%A).sql
    echo "Importing Database Production"
    cd /home/postgres/production
    PGPASSWORD=$POSTGRESQL_POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --username postgres $POSTGRESQL_DB_PRODUCTION < ${POSTGRESQL_DB_PRODUCTION}-$(date +\%A).sql
    echo "Importing success and database is ready"
  fi
else 
  echo "Database is not ready to import"
  if [ -n "$POSTGRESQL_MULTIPLE_DATABASES" ]; then
    echo "Multiple database creation requested: $POSTGRESQL_MULTIPLE_DATABASES"
    for db in $(echo $POSTGRESQL_MULTIPLE_DATABASES | tr ',' ' '); do
      create_database $db
    done
    echo "Database is ready"
  fi
fi