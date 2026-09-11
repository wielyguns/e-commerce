<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

/*
|--------------------------------------------------------------------------
| Admin routes (prefix: /admin, name: admin.*)
|--------------------------------------------------------------------------
| Loaded by bootstrap/app.php inside the "web" group. Role protection
| (->middleware('role:admin')) is wired up in Phase E once Fortify auth and
| the spatie roles seeder exist.
*/

Route::get('/', function () {
    return Inertia::render('Admin/Dashboard', [
        'stats' => [
            'orders' => 0,
            'revenue' => 0,
            'lowStock' => 0,
        ],
    ]);
})->name('dashboard');
