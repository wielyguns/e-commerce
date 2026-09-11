<script setup>
import { Link } from '@inertiajs/vue3';

const nav = [
    { label: 'Dashboard', href: '/admin', icon: 'pi pi-gauge' },
    { label: 'Produk', href: '/admin/products', icon: 'pi pi-book' },
    { label: 'Pesanan', href: '/admin/orders', icon: 'pi pi-receipt' },
];
</script>

<template>
    <div class="flex min-h-screen bg-surface-100 dark:bg-surface-950">
        <!-- Sidebar -->
        <aside class="hidden w-60 shrink-0 flex-col border-r border-surface-200 bg-white md:flex dark:border-surface-800 dark:bg-surface-900">
            <div class="flex h-16 items-center gap-2 border-b border-surface-200 px-5 dark:border-surface-800">
                <i class="pi pi-book text-xl text-primary-600" />
                <span class="font-bold">JPBook Admin</span>
            </div>
            <nav class="flex-1 space-y-1 p-3">
                <Link
                    v-for="item in nav"
                    :key="item.href"
                    :href="item.href"
                    class="flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium text-surface-700 hover:bg-surface-100 dark:text-surface-200 dark:hover:bg-surface-800"
                >
                    <i :class="item.icon" />
                    {{ item.label }}
                </Link>
            </nav>
        </aside>

        <!-- Main -->
        <div class="flex min-w-0 flex-1 flex-col">
            <header class="flex h-16 items-center justify-between border-b border-surface-200 bg-white px-6 dark:border-surface-800 dark:bg-surface-900">
                <h1 class="text-lg font-semibold">
                    <slot name="header">Admin</slot>
                </h1>
                <Link href="/" class="text-sm text-surface-500 hover:text-primary-600">← Kembali ke toko</Link>
            </header>
            <main class="flex-1 p-6">
                <slot />
            </main>
        </div>
    </div>
</template>
