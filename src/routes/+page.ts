import type { PageLoad } from './$types';

export const load: PageLoad = async ({ url, fetch }) => {
	const origin = url.origin;

	const [pingRes, capturesRes] = await Promise.all([fetch('/api/ping'), fetch('/api/captures')]);

	let ping: unknown = null;
	if (pingRes.ok) {
		ping = await pingRes.json();
	}

	let captures: unknown = null;
	if (capturesRes.ok) {
		captures = await capturesRes.json();
	}

	return {
		origin,
		ping,
		captures
	};
};
