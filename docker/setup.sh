#!/usr/bin/env bash
# One-shot bootstrap, run by the `setup` service on every `docker compose up`.
# Idempotent: creates .env + APP_KEY on a fresh clone, keeps composer/npm
# dependencies in sync with the lockfiles and applies pending migrations.
set -euo pipefail
cd /app

if [ ! -f .env ]; then
    echo "[setup] creating .env from .env.example"
    cp .env.example .env
fi

echo "[setup] composer install"
composer install --no-interaction --prefer-dist --no-progress

# npm ci only when node_modules is missing or older than the lockfile.
if [ package-lock.json -nt node_modules/.package-lock.json ]; then
    echo "[setup] npm ci"
    npm ci --no-audit --no-fund
fi

if ! grep -q '^APP_KEY=base64:' .env; then
    echo "[setup] generating APP_KEY"
    php artisan key:generate --force
fi

echo "[setup] migrate"
php artisan migrate --force

# The container runs as root; hand generated files back to whoever owns the
# project directory so they stay editable from the host.
owner="$(stat -c '%u:%g' /app)"
if [ "$owner" != "0:0" ]; then
    chown -R "$owner" .env vendor node_modules
fi

echo "[setup] done"
