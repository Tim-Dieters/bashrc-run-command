import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

const API_URL = import.meta.env.VITE_API_URL;

const api = createApi({
    reducerPath: 'api',
    baseQuery: fetchBaseQuery({
        baseUrl: API_URL,
        prepareHeaders: (headers) => {
            headers.set('Content-Type', 'application/json');
            return headers;
        },
        fetchFn: async (input, init) => {
            if (init?.method === 'OPTIONS') {
                const corsHeaders = {
                    'Access-Control-Allow-Origin': window.location.origin,
                    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
                };
                return new Response(null, { status: 204, headers: corsHeaders });
            }
            return fetch(input, init);
        }
    }),
    endpoints: () => ({}),
});

export default api;