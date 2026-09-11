#!/bin/bash
# Custom entrypoint for the read REPLICA.
# On first boot it clones the primary with pg_basebackup; thereafter it just
# starts Postgres in hot-standby (read-only) mode and streams WAL.
set -e

: "${PGDATA:=/var/lib/postgresql/data}"

if [ -z "$(ls -A "$PGDATA" 2>/dev/null)" ]; then
    echo "[replica] waiting for primary '$PRIMARY_HOST' to accept connections..."
    until pg_isready -h "$PRIMARY_HOST" -p 5432 -U "$POSTGRES_USER" >/dev/null 2>&1; do
        sleep 2
    done

    echo "[replica] cloning primary via pg_basebackup..."
    gosu postgres pg_basebackup \
        -d "host=$PRIMARY_HOST port=5432 user=replicator password=$REPLICATION_PASSWORD" \
        -D "$PGDATA" -Fp -Xs -P -R
    chmod 0700 "$PGDATA"
    echo "[replica] base backup complete; starting hot standby"
fi

exec docker-entrypoint.sh postgres -c hot_standby=on
