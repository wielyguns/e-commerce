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
docker compose up -d --build
```

That's it — also on a fresh clone. The one-shot `setup` service (`docker/setup.sh`)
runs on every `up`: it creates `.env` from `.env.example`, runs `composer install` /
`npm ci`, generates `APP_KEY` and applies migrations. The app, queue worker and Vite
start only after it succeeds (first run takes a few minutes for dependencies).

Then open:

| URL                              | What                                   |
| -------------------------------- | -------------------------------------- |
| http://localhost:8089            | Storefront (Inertia/Vue)               |
| http://localhost:8089/admin      | Admin panel (role-protected in Phase E)|
| http://localhost:8089/horizon    | Horizon queue dashboard                |

> Port taken? Set `APP_PORT` in `.env` (`APP_URL` follows it) and run
> `docker compose up -d` again.

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
