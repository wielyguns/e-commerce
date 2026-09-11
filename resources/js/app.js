import '../css/app.css';
import 'primeicons/primeicons.css';

import { createApp, h } from 'vue';
import { createInertiaApp } from '@inertiajs/vue3';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import { ZiggyVue } from 'ziggy-js';

import PrimeVue from 'primevue/config';
import Aura from '@primeuix/themes/aura';
import ToastService from 'primevue/toastservice';
import ConfirmationService from 'primevue/confirmationservice';

const appName = import.meta.env.VITE_APP_NAME || 'JPBook';

createInertiaApp({
    title: (title) => (title ? `${title} — ${appName}` : appName),

    resolve: (name) =>
        resolvePageComponent(
            `./Pages/${name}.vue`,
            import.meta.glob('./Pages/**/*.vue'),
        ),

    setup({ el, App, props, plugin }) {
        createApp({ render: () => h(App, props) })
            .use(plugin)
            .use(ZiggyVue)
            .use(PrimeVue, {
                theme: {
                    preset: Aura,
                    options: {
                        darkModeSelector: '.dark',
                        // Keep PrimeVue styles in a lower cascade layer so
                        // Tailwind utilities can override component defaults.
                        cssLayer: {
                            name: 'primevue',
                            order: 'theme, base, primevue, utilities',
                        },
                    },
                },
            })
            .use(ToastService)
            .use(ConfirmationService)
            .mount(el);
    },

    progress: {
        color: '#4f46e5',
    },
});
