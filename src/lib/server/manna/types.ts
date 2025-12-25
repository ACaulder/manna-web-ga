// src/lib/server/manna/types.ts

export interface MannaFileTiming {
	duration_sec: number | null;
	created_at_utc: string | null;
}

export interface MannaFileAsr {
	engine: string;
	model_name: string;
	language: string;
}

export interface MannaFileDiarization {
	enabled: boolean;
	num_speakers: number | null;
	speaker_ids: string[];
}

export interface MannaFileSource {
	type: 'audio';
	source_root: string | null;
	original_audio_hint: string | null;
}

export interface MannaFileInfo {
	id: string;
	whisperx_json_path: string;
	clean_txt_path: string;
	relative_dir: string;
	basename: string;
}

export interface MannaPerson {
	name: string;
	role: string; // e.g. 'self', 'family', 'friend', 'coworker', 'romantic_interest', etc.
	description: string;
	importance: 'low' | 'medium' | 'high' | string;
	example_quotes: string[];
}

export interface MannaRelationship {
	between: [string, string];
	type: string; // e.g. 'family', 'romantic', 'coworker', 'mentor', etc.
	status: string; // e.g. 'growing', 'stable', 'strained', 'distant', etc.
	summary: string;
	tension_points: string[];
	growth_opportunities: string[];
	priority: 'low' | 'medium' | 'high' | string;
}

export interface MannaCommitment {
	owner: string; // usually 'Andrew'
	action: string; // what needs to happen
	context: string; // e.g. 'dating – Ashley', 'work – Manna PE V2'
	deadline: string | null; // freeform or ISO date
	status: string; // 'open', 'done', etc.
	source_quote: string;
}

export interface MannaTopic {
	name: string;
	category: string; // 'project', 'area_of_life', 'habit', etc.
	summary: string;
	importance: 'low' | 'medium' | 'high' | string;
}

export interface MannaHighlight {
	type: string; // 'insight', 'decision', 'prayer', etc.
	content: string;
	reason: string;
}

export interface MannaInsightsMeta {
	engine: string; // 'openai'
	model: string;
	temperature: number;
	max_chars: number;
	created_at_utc: string;
	truncated_transcript: boolean;
	schema_version: string;
}

export interface MannaFile {
	version: string;
	file: MannaFileInfo;
	source: MannaFileSource;
	asr: MannaFileAsr;
	timing: MannaFileTiming;
	diarization: MannaFileDiarization;
	people: MannaPerson[];
	relationships: MannaRelationship[];
	commitments: MannaCommitment[];
	topics: MannaTopic[];
	highlights: MannaHighlight[];
	tags: string[];
	notes?: string;
	insights?: MannaInsightsMeta;
}

export interface MannaSummary {
	files: MannaFile[];
	peopleIndex: {
		[name: string]: {
			name: string;
			roles: string[];
			appearances: number;
			importanceScore: number;
			files: string[]; // file ids
			commitments: MannaCommitment[];
			relationships: MannaRelationship[];
			tags: string[];
		};
	};
	openCommitments: MannaCommitment[];
}
