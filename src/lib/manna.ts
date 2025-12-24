// src/lib/manna.ts

export type MannaItem = {
	id: string;
	title: string;
	verse: string;
	reference: string;
	note?: string;
};

export const MANNA_ITEMS: MannaItem[] = [
	{
		id: 'daily-bread',
		title: 'Daily Bread',
		verse: 'Give us today our daily bread.',
		reference: 'Matthew 6:11',
		note: 'Stay focused on today’s portion instead of tomorrow’s pressure.'
	},
	{
		id: 'anchored-hope',
		title: 'Anchored Hope',
		verse: 'We have this hope as an anchor for the soul, firm and secure.',
		reference: 'Hebrews 6:19',
		note: 'Hope is not vague optimism; it’s a stabilizing weight in the water.'
	},
	{
		id: 'spirit-led',
		title: 'Spirit-Led',
		verse: 'Those who are led by the Spirit of God are the children of God.',
		reference: 'Romans 8:14',
		note: 'Identity first, direction second. You’re led because you belong.'
	}
];
