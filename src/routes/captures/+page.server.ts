import type { PageServerLoad } from './$types';
import type { CapturesPayload } from '$lib/schema';

export const load: PageServerLoad = async ({ fetch }) => {
	let payload: CapturesPayload | null = null;

	try {
		const res = await fetch('/api/captures');
		if (res.ok) {
			payload = (await res.json()) as CapturesPayload;
		}
	} catch {
		payload = null;
	}

	const captures = payload?.captures ?? [];
	const summary = payload?.summary ?? null;

	return {
		captures,
		summary
	};
};
