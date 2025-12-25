import type { RequestHandler } from '@sveltejs/kit';

export const GET: RequestHandler = () => {
	const body = `User-agent: *
Disallow: /`;

	return new Response(body, {
		headers: {
			'Content-Type': 'text/plain',
			'Cache-Control': 'public, max-age=3600',
			'X-Robots-Tag': 'noindex, nofollow'
		}
	});
};
