FROM ubuntu:18.04

LABEL maintainer David Sugianto <idiots718@gmail.com>

ENV POSTGRESQL_USER=${POSTGRESQL_USER} \
    POSTGRESQL_PASSWORD=${POSTGRESQL_PASSWORD} \
    POSTGRESQL_HOST=${POSTGRESQL_HOST} \
    POSTGRSQL_PORT=${POSTGRSQL_PORT} \
    POSTGRESQL_STAGING_DATABASE=${POSTGRESQL_STAGING_DATABASE} \
    POSTGRESQL_PRODUCTION_DATABASE=${POSTGRESQL_PRODUCTION_DATABASE}

RUN apt update -y && apt install -y curl cron postgresql-client

RUN mkdir -p /backups/staging && chmod -R 777 /backups/staging
RUN mkdir -p /backups/production && chmod -R 777 /backups/production
RUN chmod -R 777 /backups

COPY ./scripts /scripts
RUN find /scripts -type f -iname "*.sh" -exec chmod a+x {} \;
VOLUME /backups

ENTRYPOINT ["/scripts/entrypoint.sh"]

