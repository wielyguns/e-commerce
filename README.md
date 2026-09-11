# JPBook — E-commerce Toko Buku

Single-seller B2C bookstore built as a **stateless Laravel monolith**, designed to scale
horizontally behind a load balancer (~10k req/min with flash-sale headroom).

- **Backend:** PHP 8.3 · Laravel 13 · Laravel Octane (FrankenPHP)
- **Frontend:** Inertia 2 · Vue 3 · Vite · Tailwind CSS 4 · PrimeVue 4
- **Data:** PostgreSQL (primary + read replica) · Redis (cache/session/queue) · Meilisearch
- **Ops:** Laravel Horizon (queues) · Laravel Scout (search)

Everything runs in Docker. The app holds **no local state** — sessions, cache and queues
live in Redis; search lives in Meilisearch; data in Postgres.

---

## Installation

### 1. Requirements

- [Git](https://git-scm.com/downloads)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/macOS) or
  Docker Engine + the Docker Compose v2 plugin (Linux)

PHP, Composer, Node and Postgres are **not** needed on your machine — they all run
inside Docker.

> **Windows:** use WSL2 and clone the project inside the Linux filesystem
> (e.g. `~/projects`), not under `C:\`. Bind mounts from `C:\` are very slow.

### 2. Clone and start

```bash
git clone https://github.com/wielyguns/e-commerce.git
cd e-commerce
docker compose up -d --build
```

No manual setup is needed. The one-shot `setup` service (`docker/setup.sh`) runs on
every `up`. It:

1. creates `.env` from `.env.example`,
2. runs `composer install` and `npm ci`,
3. generates `APP_KEY`,
4. applies database migrations.

The app, queue worker and Vite start only after it succeeds. The first run takes a
few minutes while dependencies download. To follow along:

```bash
docker compose logs -f setup      # ends with "[setup] done"
```

### 3. Open the app

| URL                              | What                                   |
| -------------------------------- | -------------------------------------- |
| http://localhost:8089            | Storefront (Inertia/Vue)               |
| http://localhost:8089/admin      | Admin panel (role-protected in Phase E)|
| http://localhost:8089/horizon    | Horizon queue dashboard                |

### Updating

```bash
git pull
docker compose up -d --build      # re-syncs dependencies and runs new migrations
```

### Stopping / uninstalling

```bash
docker compose down               # stop, keep the database
docker compose down -v            # stop and DELETE all data (database, Redis, search index)
```

### Troubleshooting

- **Port `8089` already in use:** set another port in `.env`, e.g. `APP_PORT=8090`
  (`APP_URL` follows it automatically), then `docker compose up -d`. `.env` is
  created on the first run; before that, copy it from `.env.example`.
- **Port `5173` already in use:** another Vite dev server is running on your
  machine. Stop it, then `docker compose up -d`.
- **App does not start:** check `docker compose logs setup`. The other services
  only start after it finishes successfully.
- **Page loads without styling:** the `vite` container serves the front-end assets.
  Check that it is running with `docker compose ps`.

## Services (docker-compose)

| Service         | Role                          | Host port |
| --------------- | ----------------------------- | --------- |
| `setup`         | One-shot bootstrap, then exits| —         |
| `app`           | Octane / FrankenPHP web server| 8089→8000 |
| `horizon`       | Queue worker (Redis)          | —         |
| `vite`          | Vite dev server (HMR)         | 5173      |
| `pgsql`         | Postgres **primary** (writes) | internal  |
| `pgsql-replica` | Postgres **replica** (reads)  | internal  |
| `redis`         | Cache · session · queue       | internal  |
| `meilisearch`   | Product search                | internal  |

Only the ports the browser needs are published, so the stack never clashes with a
Postgres/Redis already running on the host.

## Architecture notes

- **Stateless:** `SESSION_DRIVER`, `CACHE_STORE`, `QUEUE_CONNECTION` all = `redis`.
- **Read/write split:** `config/database.php` routes `SELECT`s to the replica and writes
  to the primary (`sticky` on, so same-request reads see fresh writes). The replica uses
  real Postgres streaming replication (see `docker/postgres/`).
- **Heavy work is queued** (Horizon) — mail, webhooks, search indexing — so user requests
  stay fast. `SCOUT_QUEUE=true` indexes products off the request path.
- **Cache-friendly catalog:** public pages avoid per-user content (ready for CDN in front).
- **Third-party integrations use the adapter pattern** (`app/Contracts` + `app/Services`),
  credentials via `.env` only, sandbox by default — Midtrans (payment) and Biteship
  (shipping) land in Phases C/D.

## Common commands

```bash
docker compose logs -f app          # tail Octane logs
docker compose exec app bash        # shell into the app container
docker compose exec app php artisan ...   # any artisan command
docker compose exec pgsql psql -U jpbook jpbook   # Postgres shell
docker compose logs setup           # see what the bootstrap did
docker compose restart app          # reload after config changes
docker compose down                 # stop (keeps data volumes)
```

## Build status

- **Phase A — Foundation:** ✅ done (this checkpoint)
- Phase B — Catalog · Phase C — Cart & checkout · Phase D — Payment · Phase E — Account & admin
