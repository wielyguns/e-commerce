<script setup>
import { Link } from '@inertiajs/vue3';

defineProps({
    title: { type: String, default: null },
});
</script>

<template>
    <div class="flex min-h-screen flex-col">
        <!-- Top bar -->
        <header class="sticky top-0 z-20 border-b border-surface-200 bg-white/80 backdrop-blur dark:border-surface-800 dark:bg-surface-900/80">
            <div class="mx-auto flex h-16 max-w-7xl items-center gap-6 px-4 sm:px-6 lg:px-8">
                <Link href="/" class="flex items-center gap-2 text-xl font-bold tracking-tight text-primary-600">
                    <i class="pi pi-book text-2xl" />
                    <span>JPBook</span>
                </Link>

                <nav class="hidden items-center gap-5 text-sm font-medium text-surface-600 md:flex dark:text-surface-300">
                    <Link href="/" class="hover:text-primary-600">Beranda</Link>
                    <Link href="/products" class="hover:text-primary-600">Katalog</Link>
                </nav>

                <div class="ml-auto flex items-center gap-3">
                    <Link href="/cart" class="relative inline-flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium text-surface-700 hover:bg-surface-100 dark:text-surface-200 dark:hover:bg-surface-800">
                        <i class="pi pi-shopping-cart" />
                        <span class="hidden sm:inline">Keranjang</span>
                    </Link>
                    <Link href="/login" class="inline-flex items-center gap-2 rounded-md bg-primary-600 px-3 py-2 text-sm font-semibold text-white hover:bg-primary-700">
                        <i class="pi pi-user" />
                        <span class="hidden sm:inline">Masuk</span>
                    </Link>
                </div>
            </div>
        </header>

        <!-- Page content -->
        <main class="mx-auto w-full max-w-7xl flex-1 px-4 py-8 sm:px-6 lg:px-8">
            <slot />
        </main>

        <!-- Footer -->
        <footer class="border-t border-surface-200 bg-white py-8 dark:border-surface-800 dark:bg-surface-900">
            <div class="mx-auto max-w-7xl px-4 text-sm text-surface-500 sm:px-6 lg:px-8">
                © {{ new Date().getFullYear() }} JPBook · Toko buku online.
            </div>
        </footer>
    </div>
</template>
