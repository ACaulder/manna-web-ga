import { createHash } from 'crypto';
// src/routes/reachout.ics/+server.ts

import type { RequestHandler } from '@sveltejs/kit';
import { buildIcsCalendar, type IcsEventConfig } from '$lib/ics';

// Simple example: three weekly reach-out anchors.
// All times in UTC, edit to taste.
const reachoutEvents: IcsEventConfig[] = [
	{
		uid: 'manna-reachout-monday-checkin',
		start: '20250106T130000Z',
		end: '20250106T133000Z',
		summary: 'Relational Check-in',
		description: 'Reach out to one friend or family member and check in.',
		rrule: 'FREQ=WEEKLY;BYDAY=MO'
	},
	{
		uid: 'manna-reachout-wednesday-encourage',
		start: '20250108T130000Z',
		end: '20250108T133000Z',
		summary: 'Encouragement Text or Call',
		description: 'Send encouragement to someone God puts on your mind.',
		rrule: 'FREQ=WEEKLY;BYDAY=WE'
	},
	{
		uid: 'manna-reachout-friday-serve',
		start: '20250110T130000Z',
		end: '20250110T140000Z',
		summary: 'Serve or Bless Someone',
		description: 'Plan one small act of service or generosity.',
		rrule: 'FREQ=WEEKLY;BYDAY=FR'
	}
];

const ICS_BODY = buildIcsCalendar({
	prodId: '-//Manna//Reachout Calendar//EN',
	events: reachoutEvents
});

export const GET: RequestHandler = ({ request }) => {
	const etag = '"' + createHash('sha256').update(ICS_BODY).digest('base64') + '"';
	const inm = request.headers.get('if-none-match');

	const headers = new Headers({
		'Content-Type': 'text/calendar; charset=utf-8',
		'Content-Disposition': 'attachment; filename="reachout.ics"',
		'Cache-Control': 'public, max-age=300',
		'X-Robots-Tag': 'noindex, nofollow'
	});
	headers.set('ETag', etag);

	if (inm && inm === etag) return new Response(null, { status: 304, headers });

	return new Response(ICS_BODY, { headers });
};
