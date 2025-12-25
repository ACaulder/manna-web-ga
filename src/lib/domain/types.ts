// src/lib/domain/types.ts
export type PersonId = string;
export type TranscriptId = string;

export interface Person {
	id: PersonId;
	name: string;
	role?: string; // SSV, barista, friend, etc.
}

export interface Commitment {
	id: string;
	owner: 'andrew' | PersonId; // who owns the action
	description: string;
	dueDate?: string; // ISO string
	status: 'open' | 'done';
}

export interface SessionSummary {
	transcriptId: TranscriptId;
	personId: PersonId;
	date: string; // ISO
	context: string; // 1 paragraph
	keyThemes: string[]; // 3–7 bullets
	shifts: string[]; // what changed
	commitments: Commitment[];
}

export interface Transcript {
	id: TranscriptId;
	personId?: PersonId;
	createdAt: string;
	rawText: string;
	summary?: SessionSummary;
}
