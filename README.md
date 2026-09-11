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

## Prerequisites

- Docker + Docker Compose (the only host requirement)

## Quick start

```bash
# 1. Environment file (already present, but for a fresh clone):
cp .env.example .env

# 2. Build the application image (FrankenPHP + PHP 8.3 + Node)
docker compose build

# 3. Install dependencies (first run only)
docker compose run --rm --no-deps app composer install
docker compose run --rm --no-deps app npm install

# 4. Start the full stack
docker compose up -d

# 5. App key + migrations (first run only)
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate
```

Then open:

| URL                              | What                                   |
| -------------------------------- | -------------------------------------- |
| http://localhost:8088            | Storefront (Inertia/Vue)               |
| http://localhost:8088/admin      | Admin panel (role-protected in Phase E)|
| http://localhost:8088/horizon    | Horizon queue dashboard                |
| http://localhost:7700            | Meilisearch                            |

> Host ports 8000/8080/5433 were already taken on this machine, so the app is
> published on **8088** (see `docker-compose.yml`).

## Services (docker-compose)

| Service         | Role                          | Host port |
| --------------- | ----------------------------- | --------- |
| `app`           | Octane / FrankenPHP web server| 8088→8000 |
| `horizon`       | Queue worker (Redis)          | —         |
| `vite`          | Vite dev server (HMR)         | 5173      |
| `pgsql`         | Postgres **primary** (writes) | 5432      |
| `pgsql-replica` | Postgres **replica** (reads)  | internal  |
| `redis`         | Cache · session · queue       | 6379      |
| `meilisearch`   | Product search                | 7700      |

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
docker compose restart app          # reload after config changes
docker compose down                 # stop (keeps data volumes)
```

## Build status

- **Phase A — Foundation:** ✅ done (this checkpoint)
- Phase B — Catalog · Phase C — Cart & checkout · Phase D — Payment · Phase E — Account & admin
