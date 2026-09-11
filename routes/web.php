<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

/*
|--------------------------------------------------------------------------
| Storefront routes (public)
|--------------------------------------------------------------------------
| Catalog/detail pages are intentionally per-user-agnostic so they stay
| cache-friendly (CDN/Cloudflare in front). Real controllers land in Phase B.
*/

Route::get('/', function () {
    return Inertia::render('Storefront/Home', [
        'appName' => config('app.name'),
        'stack' => [
            ['name' => 'Laravel 13 + Octane', 'detail' => 'FrankenPHP, stateless workers'],
            ['name' => 'Inertia 2 + Vue 3', 'detail' => 'Monolith SPA, Vite + PrimeVue'],
            ['name' => 'PostgreSQL', 'detail' => 'Read/write split (primary + replica)'],
            ['name' => 'Redis', 'detail' => 'Cache · session · queue'],
            ['name' => 'Horizon', 'detail' => 'Queue worker dashboard'],
            ['name' => 'Meilisearch', 'detail' => 'Laravel Scout product search'],
        ],
    ]);
})->name('home');
