const FIXED_ICS_DTSTAMP = '20250101T000000Z';

// src/lib/ics.ts

export type IcsEventConfig = {
	uid: string;
	start: string; // UTC, e.g. 20250101T120000Z
	end: string; // UTC, e.g. 20250101T123000Z
	summary: string;
	description?: string;
	rrule?: string;
	location?: string;
};

/**
 * Escape text fields to be safe for ICS.
 */
function escapeText(text: string): string {
	return text
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/,/g, '\\,')
		.replace(/;/g, '\\;');
}

/**
 * Format current UTC time as YYYYMMDDTHHMMSSZ for DTSTAMP.
 */

/**
 * Build a full ICS calendar string from a list of events.
 */
export function buildIcsCalendar(opts: { prodId?: string; events: IcsEventConfig[] }): string {
	const prodId = opts.prodId ?? '-//Manna//Calendar 1.0//EN';
	const dtstamp = FIXED_ICS_DTSTAMP;

	const lines: string[] = [
		'BEGIN:VCALENDAR',
		'VERSION:2.0',
		'CALSCALE:GREGORIAN',
		`PRODID:${prodId}`,
		'METHOD:PUBLISH'
	];

	for (const ev of opts.events) {
		lines.push('BEGIN:VEVENT');
		lines.push(`UID:${ev.uid}`);
		lines.push(`DTSTAMP:${dtstamp}`);
		lines.push(`DTSTART:${ev.start}`);
		lines.push(`DTEND:${ev.end}`);
		lines.push(`SUMMARY:${escapeText(ev.summary)}`);

		if (ev.description) {
			lines.push(`DESCRIPTION:${escapeText(ev.description)}`);
		}

		if (ev.location) {
			lines.push(`LOCATION:${escapeText(ev.location)}`);
		}

		if (ev.rrule) {
			lines.push(`RRULE:${ev.rrule}`);
		}

		lines.push('END:VEVENT');
	}

	lines.push('END:VCALENDAR');

	return lines.join('\r\n');
}
