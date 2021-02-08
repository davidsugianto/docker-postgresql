FROM ubuntu:18.04

LABEL maintainer David Sugianto <idiots718@gmail.com>

ENV POSTGRESQL_USER=${POSTGRESQL_USER} \
    POSTGRESQL_PASSWORD=${POSTGRESQL_PASSWORD} \
    POSTGRESQL_HOST=${POSTGRESQL_HOST} \
    POSTGRESQL_PORT=${POSTGRSQL_PORT} \
    POSTGRESQL_STAGING_DATABASE=${POSTGRESQL_STAGING_DATABASE} \
    POSTGRESQL_PRODUCTION_DATABASE=${POSTGRESQL_PRODUCTION_DATABASE}

COPY ./scripts /scripts

RUN apt update -y && apt install -y curl cron postgresql-client && \
    mkdir -p /backups/staging && chmod -R 777 /backups/staging && \
    mkdir -p /backups/production && chmod -R 777 /backups/production && \
    chmod -R 777 /backups && \
    find /scripts -type f -iname "*.sh" -exec chmod a+x {} \; && \
    mkdir -p /var/log/db_dump && chmod -R 777 /var/log/db_dump

VOLUME ["/backups", "/var/log"]

ENTRYPOINT ["/scripts/entrypoint.sh"]

