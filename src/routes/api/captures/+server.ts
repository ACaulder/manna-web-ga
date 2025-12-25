import type { RequestHandler } from './$types';

type BeItem = {
	statement: string;
	practices?: string[];
};

type KnowItem = {
	truth: string;
	lie?: string;
};

type DoItem = {
	action: string;
	due?: string;
};

type FeelItem = {
	current_emotion: string;
	desired_direction?: string;
};

type Person = {
	person_id: string;
	name?: string;
	relationship?: string;
	domains?: string[];
	note?: string;
};

type Capture = {
	id: string;
	date: string;
	title?: string;
	be: BeItem[];
	know: KnowItem[];
	do: DoItem[];
	feel: FeelItem[];
	people: Person[];
};

const captures: Capture[] = [
	{
		id: '2025-10-22-ashley-andrew',
		date: '2025-10-22',
		title: 'Ashley + Andrew – check-in',
		be: [
			{
				statement: 'Be present and gentle in conversations that matter.',
				practices: [
					'Slow your pace before answering.',
					'Ask one clarifying question before giving advice.',
					'Return to Scripture instead of spinning in your head.'
				]
			}
		],
		know: [
			{
				truth: 'God is with us in the process, not just the outcome.',
				lie: 'If it isn’t perfect, it doesn’t matter.'
			}
		],
		do: [
			{
				action: 'Send Ashley a short voice note tonight recapping the core encouragement.',
				due: '2025-10-22'
			}
		],
		feel: [
			{
				current_emotion: 'Tired but hopeful.',
				desired_direction: 'Rooted, steady, and quietly confident.'
			}
		],
		people: [
			{
				person_id: 'andrew',
				name: 'Andrew',
				relationship: 'self',
				domains: ['leadership', 'calling'],
				note: 'Processing direction, responsibility, and capacity.'
			},
			{
				person_id: 'ashley',
				name: 'Ashley',
				relationship: 'friend',
				domains: ['community', 'Temple Studio'],
				note: 'Co-laborer in vision; needs clarity and encouragement.'
			}
		]
	}
];

export const GET: RequestHandler = async () => {
	const summary = {
		total: captures.length,
		captured: captures.length,
		transcribed: captures.length,
		structured: captures.length,
		reviewed: 0
	};

	const payload = {
		captures,
		summary
	};

	return new Response(JSON.stringify(payload), {
		status: 200,
		headers: {
			'Content-Type': 'application/json'
		}
	});
};
