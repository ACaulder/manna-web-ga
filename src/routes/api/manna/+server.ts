// src/routes/api/manna/+server.ts

import type { RequestHandler } from '@sveltejs/kit';
import { MANNA_ITEMS } from '$lib/manna';

export const GET: RequestHandler = () => {
	const body = {
		items: MANNA_ITEMS
	};

	return new Response(JSON.stringify(body), {
		headers: {
			'Content-Type': 'application/json; charset=utf-8',
			'Cache-Control': 'no-store',
			'X-Robots-Tag': 'noindex, nofollow'
		}
	});
};
