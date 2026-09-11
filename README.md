# JPBook — E-commerce Toko Buku

Toko buku online B2C dengan satu penjual, dibangun sebagai **monolit Laravel stateless**
yang siap di-scale horizontal di belakang load balancer (~10 ribu request/menit, dengan
ruang cadangan untuk flash sale).

- **Backend:** PHP 8.3 · Laravel 13 · Laravel Octane (FrankenPHP)
- **Frontend:** Inertia 2 · Vue 3 · Vite · Tailwind CSS 4 · PrimeVue 4
- **Data:** PostgreSQL (primary + read replica) · Redis (cache/session/queue) · Meilisearch
- **Ops:** Laravel Horizon (queue) · Laravel Scout (pencarian)

Semuanya berjalan di Docker. Aplikasi **tidak menyimpan state lokal**: session, cache, dan
queue ada di Redis; pencarian di Meilisearch; data di Postgres.

---

## Instalasi

### 1. Kebutuhan

- [Git](https://git-scm.com/downloads)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/macOS), atau
  Docker Engine + plugin Docker Compose v2 (Linux)

PHP, Composer, Node, dan Postgres **tidak** perlu diinstal di komputer. Semuanya
berjalan di dalam Docker.

> **Windows:** gunakan WSL2 dan clone project di dalam filesystem Linux
> (misalnya `~/projects`), jangan di `C:\`. Bind mount dari `C:\` sangat lambat.

### 2. Clone dan jalankan

```bash
git clone https://github.com/wielyguns/e-commerce.git
cd e-commerce
docker compose up -d --build
```

Tidak perlu setup manual. Service `setup` (`docker/setup.sh`) berjalan sekali setiap
kali `up`, lalu berhenti. Tugasnya:

1. membuat `.env` dari `.env.example`,
2. menjalankan `composer install` dan `npm ci`,
3. membuat `APP_KEY`,
4. menjalankan migrasi database.

App, queue worker, dan Vite baru start setelah `setup` selesai tanpa error. Proses
pertama butuh beberapa menit untuk mengunduh dependency. Untuk memantaunya:

```bash
docker compose logs -f setup      # selesai kalau muncul "[setup] done"
```

### 3. Buka aplikasinya

| URL                              | Isi                                            |
| -------------------------------- | ---------------------------------------------- |
| http://localhost:8089            | Halaman toko (Inertia/Vue)                     |
| http://localhost:8089/admin      | Panel admin (proteksi role menyusul di Fase E) |
| http://localhost:8089/horizon    | Dashboard queue Horizon                        |

### Update

```bash
git pull
docker compose up -d --build      # sinkronkan dependency dan jalankan migrasi baru
```

### Menghentikan / menghapus

```bash
docker compose down               # hentikan, database tetap tersimpan
docker compose down -v            # hentikan dan HAPUS semua data (database, Redis, indeks pencarian)
```

### Troubleshooting

- **Port `8089` sudah dipakai:** atur port lain di `.env`, misalnya `APP_PORT=8090`
  (`APP_URL` otomatis mengikuti), lalu jalankan `docker compose up -d`. File `.env`
  dibuat saat pertama kali `up`; kalau belum ada, salin dulu dari `.env.example`.
- **Port `5173` sudah dipakai:** ada Vite dev server lain yang sedang jalan di komputer.
  Hentikan dulu, lalu jalankan `docker compose up -d`.
- **Aplikasi tidak mau start:** cek `docker compose logs setup`. Service lain baru
  start setelah `setup` selesai tanpa error.
- **Halaman tampil tanpa styling:** aset front-end dilayani oleh container `vite`.
  Pastikan container itu jalan dengan `docker compose ps`.

## Service (docker-compose)

| Service         | Fungsi                                | Port host |
| --------------- | ------------------------------------- | --------- |
| `setup`         | Bootstrap sekali jalan, lalu berhenti | —         |
| `app`           | Web server Octane / FrankenPHP        | 8089→8000 |
| `horizon`       | Queue worker (Redis)                  | —         |
| `vite`          | Vite dev server (HMR)                 | 5173      |
| `pgsql`         | Postgres **primary** (tulis)          | internal  |
| `pgsql-replica` | Postgres **replica** (baca)           | internal  |
| `redis`         | Cache · session · queue               | internal  |
| `meilisearch`   | Pencarian produk                      | internal  |

Hanya port yang dibutuhkan browser yang dibuka ke host, jadi stack ini tidak bentrok
dengan Postgres/Redis lain yang sudah jalan di komputer.

## Catatan arsitektur

- **Stateless:** `SESSION_DRIVER`, `CACHE_STORE`, dan `QUEUE_CONNECTION` semuanya `redis`.
- **Pemisahan baca/tulis:** `config/database.php` mengarahkan query `SELECT` ke replica
  dan query tulis ke primary (`sticky` aktif, jadi data yang baru ditulis langsung
  terbaca di request yang sama). Replica memakai streaming replication Postgres
  sungguhan (lihat `docker/postgres/`).
- **Pekerjaan berat masuk queue** (Horizon), seperti email, webhook, dan indexing
  pencarian, supaya request user tetap cepat. `SCOUT_QUEUE=true` membuat indexing
  produk tidak memperlambat request.
- **Katalog ramah cache:** halaman publik tidak berisi konten per-user (siap dipasang
  CDN di depannya).
- **Integrasi pihak ketiga memakai adapter pattern** (`app/Contracts` + `app/Services`).
  Kredensial hanya lewat `.env` dan default-nya mode sandbox. Midtrans (pembayaran)
  dan Biteship (pengiriman) menyusul di Fase C/D.

## Perintah yang sering dipakai

```bash
docker compose logs -f app          # lihat log Octane
docker compose exec app bash        # masuk ke shell container app
docker compose exec app php artisan ...   # jalankan perintah artisan
docker compose exec pgsql psql -U jpbook jpbook   # shell Postgres
docker compose logs setup           # lihat apa saja yang dikerjakan setup
docker compose restart app          # reload setelah mengubah konfigurasi
docker compose down                 # hentikan (data tetap tersimpan)
```

## Status pengembangan

- **Fase A — Fondasi:** ✅ selesai (checkpoint ini)
- Fase B — Katalog · Fase C — Keranjang & checkout · Fase D — Pembayaran · Fase E — Akun & admin
