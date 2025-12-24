// src/routes/manna/relationships/+page.server.ts

import type { PageServerLoad } from './$types';
import { buildSummary } from '$lib/server/manna/fsStore';

export const load: PageServerLoad = async () => {
  const summary = buildSummary();
  const people = Object.values(summary.peopleIndex).sort(
    (a, b) => b.importanceScore - a.importanceScore
  );
  const openCommitments = summary.openCommitments;

  return {
    people,
    openCommitments,
    fileCount: summary.files.length
  };
};