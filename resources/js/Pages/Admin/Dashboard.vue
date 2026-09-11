<script setup>
import { Head } from '@inertiajs/vue3';
import AdminLayout from '@/Layouts/AdminLayout.vue';

defineProps({
    stats: {
        type: Object,
        default: () => ({ orders: 0, revenue: 0, lowStock: 0 }),
    },
});

const cards = [
    { key: 'orders', label: 'Pesanan', icon: 'pi pi-receipt', color: 'text-primary-600' },
    { key: 'revenue', label: 'Penjualan (Rp)', icon: 'pi pi-wallet', color: 'text-green-600' },
    { key: 'lowStock', label: 'Stok menipis', icon: 'pi pi-exclamation-triangle', color: 'text-amber-500' },
];
</script>

<template>
    <Head title="Admin Dashboard" />

    <AdminLayout>
        <template #header>Dashboard</template>

        <div class="grid grid-cols-1 gap-5 sm:grid-cols-3">
            <div
                v-for="card in cards"
                :key="card.key"
                class="rounded-xl border border-surface-200 bg-white p-6 shadow-sm dark:border-surface-800 dark:bg-surface-900"
            >
                <div class="flex items-center justify-between">
                    <span class="text-sm font-medium text-surface-500">{{ card.label }}</span>
                    <i :class="[card.icon, card.color, 'text-xl']" />
                </div>
                <div class="mt-3 text-3xl font-bold">{{ stats[card.key] ?? 0 }}</div>
            </div>
        </div>

        <p class="mt-8 text-sm text-surface-500">
            Placeholder dashboard — metrik nyata akan diisi pada Fase E (panel admin).
        </p>
    </AdminLayout>
</template>
