<script setup>
import { Head } from '@inertiajs/vue3';
import StorefrontLayout from '@/Layouts/StorefrontLayout.vue';
import Button from 'primevue/button';
import Tag from 'primevue/tag';

defineProps({
    appName: { type: String, default: 'JPBook' },
    stack: { type: Array, default: () => [] },
});
</script>

<template>
    <Head title="Beranda" />

    <StorefrontLayout>
        <!-- Hero -->
        <section class="overflow-hidden rounded-2xl bg-gradient-to-br from-primary-600 to-indigo-700 px-8 py-16 text-white shadow-lg">
            <div class="max-w-2xl">
                <Tag value="Phase A · Fondasi siap" severity="contrast" class="mb-4" />
                <h1 class="text-4xl font-bold leading-tight sm:text-5xl">
                    Temukan buku favoritmu di {{ appName }}
                </h1>
                <p class="mt-4 text-lg text-white/80">
                    Toko buku online dengan ribuan judul. Arsitektur stateless siap di-scale
                    untuk lonjakan flash sale.
                </p>
                <div class="mt-8 flex flex-wrap gap-3">
                    <Button label="Jelajahi Katalog" icon="pi pi-search" size="large" severity="contrast" />
                    <Button label="Kategori" icon="pi pi-th-large" size="large" outlined class="!text-white !border-white/40" />
                </div>
            </div>
        </section>

        <!-- Stack confirmation (foundation smoke test) -->
        <section class="mt-12">
            <h2 class="text-xl font-semibold">Stack terpasang</h2>
            <p class="mt-1 text-sm text-surface-500">Komponen fondasi yang aktif pada environment ini.</p>
            <div class="mt-5 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                <div
                    v-for="item in stack"
                    :key="item.name"
                    class="flex items-start gap-3 rounded-xl border border-surface-200 bg-white p-5 shadow-sm dark:border-surface-800 dark:bg-surface-900"
                >
                    <i class="pi pi-check-circle mt-0.5 text-xl text-green-500" />
                    <div>
                        <div class="font-semibold">{{ item.name }}</div>
                        <div class="text-sm text-surface-500">{{ item.detail }}</div>
                    </div>
                </div>
            </div>
        </section>
    </StorefrontLayout>
</template>
