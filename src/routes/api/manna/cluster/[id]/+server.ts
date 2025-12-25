import type { RequestHandler } from '@sveltejs/kit';
import { getDocsForCluster } from '$lib/server/manna'; // your own helper

export const GET: RequestHandler = async ({ params }) => {
	const id = params.id!;
	const docs = await getDocsForCluster(id); // return [{ id, timestamp, snippet }, ...]

	return new Response(JSON.stringify(docs), {
		headers: { 'Content-Type': 'application/json' }
	});
};
