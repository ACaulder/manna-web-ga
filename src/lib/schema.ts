// src/lib/schema.ts
// Core Manna domain types shared across the app

//
// 1. Scripture & tagging
//

export type ScriptureRef = {
  book: string; // e.g. "Exodus"
  chapter?: number;
  verse_start?: number;
  verse_end?: number;
  note?: string; // e.g. "Tabernacle completion ties to this moment"
};

export type DomainTag =
  | 'work'
  | 'church'
  | 'family'
  | 'friendship'
  | 'romance'
  | 'fitness'
  | 'finance'
  | 'learning'
  | 'calling'
  | 'other'
  | string; // allow future custom tags

export type EmotionCategory =
  | 'joy'
  | 'peace'
  | 'hope'
  | 'gratitude'
  | 'sadness'
  | 'anger'
  | 'fear'
  | 'shame'
  | 'confusion'
  | 'other'
  | string;

//
// 2. BE / KNOW / DO / FEEL
//

export type BeItem = {
  /**
   * Who you are choosing to be today in concrete words.
   * Example: "Be present and gentle in conversations that matter."
   */
  statement: string;
  /**
   * Simple, repeatable practices that reinforce that way of being.
   * Example: ["Slow your pace before answering.", "Ask one clarifying question."]
   */
  practices?: string[];
  /**
   * Optional scripture anchors that ground this BE in the Word.
   */
  scripture_refs?: ScriptureRef[];
};

export type KnowItem = {
  /**
   * Truth you are choosing to hold.
   * Example: "God is with me in the process, not just the outcome."
   */
  truth: string;
  /**
   * The lie or distortion this truth confronts.
   * Example: "If it isn't perfect, it doesn't matter."
   */
  lie?: string;
  scripture_refs?: ScriptureRef[];
};

export type DoItem = {
  /**
   * Concrete action flowing from BE/KNOW.
   * Example: "Send Ashley a short voice note tonight."
   */
  action: string;
  /**
   * Due date for this action (ISO date or human-readable).
   */
  due?: string;
  /**
   * How important this action is, relative to other DOs.
   */
  priority?: 'low' | 'normal' | 'high';
  scripture_refs?: ScriptureRef[];
};

export type FeelItem = {
  /**
   * Honest, current emotional state in your own words.
   * Example: "Tired but hopeful."
   */
  current_emotion: string;
  /**
   * Where you desire to move emotionally.
   * Example: "Rooted, steady, quietly confident."
   */
  desired_direction?: string;
  /**
   * Optional category for easier querying.
   */
  category?: EmotionCategory;
};

//
// 3. People & relationships
//

export type RelationshipType =
  | 'self'
  | 'family'
  | 'friend'
  | 'romantic'
  | 'work'
  | 'church'
  | 'mentor'
  | 'mentee'
  | 'acquaintance'
  | 'other'
  | string;

export type Person = {
  /**
   * Stable identifier used across the system.
   * For now, keep using person_id everywhere for compatibility.
   */
  person_id: string;
  /**
   * Human-readable name.
   */
  name?: string;
  /**
   * How this person relates to you.
   */
  relationship?: RelationshipType;
  /**
   * Key domains they touch in your life.
   * Example: ["church", "calling"]
   */
  domains?: DomainTag[];
  /**
   * Short note / tag-line about this person.
   */
  note?: string;
};

export type PersonDossier = Person & {
  /**
   * Brief "snapshot" summary of who they are and what matters right now.
   */
  snapshot?: string;
  /**
   * Core roles they play in your life (and you in theirs).
   * Example: ["Co-laborer in Temple Studio vision", "Friend", "Prayer partner"]
   */
  roles?: string[];
  /**
   * High-level story notes / background.
   */
  story?: string;
  /**
   * What you are currently praying for / paying attention to.
   */
  prayer_focus?: string;
  /**
   * Specific needs or pressure points they are carrying.
   */
  current_needs?: string[];
  /**
   * Date you first saw them in a capture (ISO).
   */
  first_seen_at?: string;
  /**
   * Date you most recently saw them in a capture (ISO).
   */
  last_seen_at?: string;
  /**
   * IDs of captures where they appear.
   */
  capture_ids?: string[];
  /**
   * When you would like to reach out next (ISO).
   */
  next_reachout_date?: string;
  /**
   * Additional free-form tags (e.g. "plant person", "UNC", "Temple Studio").
   */
  tags?: string[];
};

export type PeoplePayload = {
  people: PersonDossier[];
};

//
// 4. Captures & summaries
//

export type CaptureMeta = {
  /**
   * Where this capture came from.
   * audio = WhisperX pipeline, manual = typed entry, import = something else.
   */
  source?: 'audio' | 'manual' | 'import';
  /**
   * Optional original file or source ID (e.g. audio filename).
   */
  source_id?: string;
  /**
   * Optional location or context label (e.g. "Miami Beach", "TJ's Midtown").
   */
  location?: string;
  /**
   * Generic tags you might want to filter by.
   */
  tags?: string[];
  /**
   * Scripture anchors for this entire capture.
   */
  scripture_refs?: ScriptureRef[];
  /**
   * When the capture was created (ISO).
   */
  created_at?: string;
  /**
   * When you last reviewed this capture (ISO).
   */
  last_reviewed_at?: string;
};

export type Capture = {
  id: string;
  /**
   * Date this capture is anchored to (usually recording or journal date).
   * Use YYYY-MM-DD where possible.
   */
  date: string;
  /**
   * Optional human-readable title.
   */
  title?: string;
  /**
   * Core BE / KNOW / DO / FEEL slices distilled from this capture.
   */
  be: BeItem[];
  know: KnowItem[];
  do: DoItem[];
  feel: FeelItem[];
  /**
   * People surfaced in this capture.
   */
  people: Person[];
  /**
   * Extra metadata that does not affect core ontology.
   */
  meta?: CaptureMeta;
};

export type CaptureSummary = {
  total: number;
  captured: number;
  transcribed: number;
  structured: number;
  reviewed: number;
};

export type CapturesPayload = {
  captures: Capture[];
  summary: CaptureSummary;
};