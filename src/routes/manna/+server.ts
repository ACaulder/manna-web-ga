import type { RequestHandler } from './$types';

/**
 * GET /api/manna/cluster/[id]
 *
 * For now this is a stub endpoint that just returns an empty list of docs.
 * This removes the broken `$lib/server/manna` import and gives the UI a
 * predictable shape: an array of `{ id, timestamp, snippet }`-like objects.
 *
 * Later, we can wire this to the worker's search API to return real docs
 * for the selected cluster.
 */
export const GET: RequestHandler = async ({ params }) => {
	const { id } = params;

	// Placeholder: no docs yet, but the endpoint is valid.
	const docs: any[] = [];

	return new Response(JSON.stringify(docs), {
		headers: {
			'content-type': 'application/json'
		}
	});
};
