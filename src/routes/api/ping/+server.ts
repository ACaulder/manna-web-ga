import type { RequestHandler } from './$types';

export const GET: RequestHandler = async () => {
	const body = {
		status: 'ok',
		env: process.env.VERCEL_ENV ?? 'local',
		timestamp: new Date().toISOString()
	};

	return new Response(JSON.stringify(body), {
		status: 200,
		headers: {
			'Content-Type': 'application/json'
		}
	});
};
