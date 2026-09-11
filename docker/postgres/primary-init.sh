#!/bin/bash
# Runs once, on first initialisation of the PRIMARY Postgres cluster.
# Creates the streaming-replication role and authorises replica connections.
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '${REPLICATION_PASSWORD}';
EOSQL

# Allow the replica (any host on the compose network) to start replication.
echo "host replication replicator all md5" >> "$PGDATA/pg_hba.conf"

echo "[primary-init] replication role created and pg_hba.conf updated"
