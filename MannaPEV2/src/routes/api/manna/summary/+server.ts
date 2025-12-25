// src/routes/api/manna/summary/+server.ts

import type { RequestHandler } from './$types';
import { json } from '@sveltejs/kit';
import { buildSummary } from '$lib/server/manna/fsStore';

export const GET: RequestHandler = async () => {
	const summary = buildSummary();

	const peopleArray = Object.values(summary.peopleIndex).sort(
		(a, b) => b.importanceScore - a.importanceScore
	);

	const openCommitments = summary.openCommitments;

	return json({
		people: peopleArray,
		openCommitments,
		fileCount: summary.files.length
	});
};
