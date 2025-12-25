import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url, fetch }) => {
	const origin = url.origin;

	// Health ping
	let ping: { status: string; env: string; timestamp: string } | null = null;
	try {
		const res = await fetch('/api/ping');
		if (res.ok) {
			ping = await res.json();
		}
	} catch {
		ping = null;
	}

	// Captures payload
	let captures: unknown = null;
	try {
		const res = await fetch('/api/captures');
		if (res.ok) {
			captures = await res.json();
		}
	} catch {
		captures = null;
	}

	return {
		origin,
		ping,
		captures
	};
};
