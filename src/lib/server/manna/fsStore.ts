// src/lib/server/manna/fsStore.ts

import fs from 'node:fs';
import path from 'node:path';
import type { MannaFile, MannaSummary, MannaCommitment, MannaRelationship } from './types';

const TRANSCRIPTS_DIR = process.env.MANNA_TRANSCRIPTS_DIR ?? 'G:\\My Drive\\Manna\\Transcripts'; // fallback; adjust if needed

function walkDir(dir: string, out: string[] = []): string[] {
	const entries = fs.readdirSync(dir, { withFileTypes: true });
	for (const entry of entries) {
		const full = path.join(dir, entry.name);
		if (entry.isDirectory()) {
			walkDir(full, out);
		} else if (entry.isFile() && entry.name.endsWith('.manna.json')) {
			out.push(full);
		}
	}
	return out;
}

export function loadAllMannaFiles(): MannaFile[] {
	if (!fs.existsSync(TRANSCRIPTS_DIR)) {
		console.warn(`[MannaStore] TRANSCRIPTS_DIR does not exist: ${TRANSCRIPTS_DIR}`);
		return [];
	}

	const files: MannaFile[] = [];
	const paths = walkDir(TRANSCRIPTS_DIR);

	for (const p of paths) {
		try {
			const raw = fs.readFileSync(p, 'utf-8');
			const data = JSON.parse(raw) as MannaFile;
			files.push(data);
		} catch (err) {
			console.error('[MannaStore] Failed to load', p, err);
		}
	}

	return files;
}

function importanceToScore(importance: string | undefined): number {
	if (!importance) return 1;
	const imp = importance.toLowerCase();
	if (imp === 'high') return 3;
	if (imp === 'medium') return 2;
	return 1;
}

export function buildSummary(): MannaSummary {
	const files = loadAllMannaFiles();

	const peopleIndex: MannaSummary['peopleIndex'] = {};
	const openCommitments: MannaCommitment[] = [];

	for (const file of files) {
		const fileId = file.file?.id ?? file.file?.basename ?? 'unknown';

		// Commitments
		for (const c of file.commitments ?? []) {
			const status = (c.status || '').toLowerCase();
			if (!status || status === 'open' || status === 'todo') {
				openCommitments.push({ ...c });
			}
		}

		// People & relationships
		for (const person of file.people ?? []) {
			const name = person.name?.trim();
			if (!name) continue;

			if (!peopleIndex[name]) {
				peopleIndex[name] = {
					name,
					roles: [],
					appearances: 0,
					importanceScore: 0,
					files: [],
					commitments: [],
					relationships: [],
					tags: []
				};
			}

			const entry = peopleIndex[name];
			entry.appearances += 1;
			entry.importanceScore += importanceToScore(person.importance);
			entry.files.push(fileId);
			if (person.role && !entry.roles.includes(person.role)) {
				entry.roles.push(person.role);
			}
		}

		// Attach commitments to owners & relationships to participants
		for (const c of file.commitments ?? []) {
			const owner = c.owner?.trim();
			if (owner && peopleIndex[owner]) {
				peopleIndex[owner].commitments.push({ ...c });
			}
		}

		for (const r of file.relationships ?? []) {
			const [a, b] = r.between ?? [];
			const aName = a?.trim();
			const bName = b?.trim();
			if (aName && peopleIndex[aName]) {
				peopleIndex[aName].relationships.push({ ...(r as MannaRelationship) });
			}
			if (bName && peopleIndex[bName] && bName !== aName) {
				peopleIndex[bName].relationships.push({ ...(r as MannaRelationship) });
			}
		}
	}

	return {
		files,
		peopleIndex,
		openCommitments
	};
}
