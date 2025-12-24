import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch }) => {
	const res = await fetch('/api/captures');
	let captures: unknown = null;

	if (res.ok) {
		captures = await res.json();
	}

	return {
		captures
	};
};
