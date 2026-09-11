<?php

namespace App\Http\Middleware;

use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    /**
     * The root template loaded on the first page visit.
     */
    protected $rootView = 'app';

    /**
     * Determines the current asset version (busts the client cache on deploy).
     */
    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    /**
     * Data shared with every Inertia response.
     *
     * Keep this lean and request-agnostic so public catalog pages stay
     * cache-friendly; per-user data should be loaded per-page instead.
     */
    public function share(Request $request): array
    {
        return [
            ...parent::share($request),

            'appName' => config('app.name'),

            // Lightweight auth payload (null when guest). Evaluated lazily.
            'auth' => [
                'user' => $request->user()
                    ? $request->user()->only('id', 'name', 'email')
                    : null,
            ],

            // One-off flash messages for toasts.
            'flash' => [
                'success' => fn () => $request->session()->get('success'),
                'error' => fn () => $request->session()->get('error'),
            ],
        ];
    }
}
