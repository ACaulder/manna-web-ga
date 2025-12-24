import type { RequestHandler } from './$types';
import type { PeoplePayload } from '$lib/schema';

const people: PeoplePayload['people'] = [
  {
    person_id: 'andrew',
    name: 'Andrew',
    relationship: 'self',
    domains: ['work', 'church', 'calling'],
    note: 'Builder of Manna; stewarding calling, capacity, and relationships.',
    snapshot: 'Balancing leadership, calling, and deep work on Manna.',
    roles: ['Self', 'Leader', 'Builder of systems'],
    story:
      'Andrew is building Manna as a digital brain to stay rooted in Scripture, track relationships, and steward his calling with clarity.',
    prayer_focus:
      'Clarity of calling, steady energy, and peace in decision-making around work and location.',
    current_needs: [
      'Sustainable rhythms of rest and deep work.',
      'Wisdom in major career and location decisions.'
    ],
    first_seen_at: '2025-10-01',
    last_seen_at: '2025-11-22',
    capture_ids: ['2025-10-22-ashley-andrew'],
    next_reachout_date: undefined,
    tags: ['builder', 'Temple Studio', 'Manna', 'Miami']
  },
  {
    person_id: 'ashley',
    name: 'Ashley',
    relationship: 'friend',
    domains: ['church', 'calling', 'fitness'],
    note: 'Co-laborer in Temple Studio vision; needs clarity and encouragement.',
    snapshot: 'Partner in vision for Temple Studio; carrying both hunger and weight.',
    roles: ['Friend', 'Co-laborer', 'Vision partner'],
    story:
      'Ashley and Andrew are exploring Temple Studio together, blending fitness, formation, and community. Conversations often touch on calling, timing, and courage.',
    prayer_focus:
      'Courage to take next steps, peace in decision-making, and protection over her health and capacity.',
    current_needs: [
      'Encouragement when the vision feels heavy.',
      'Clarity on next right steps with Temple Studio.'
    ],
    first_seen_at: '2025-10-14',
    last_seen_at: '2025-11-22',
    capture_ids: ['2025-10-22-ashley-andrew'],
    next_reachout_date: '2025-11-30',
    tags: ['Temple Studio', 'friend', 'co-laborer']
  }
];

export const GET: RequestHandler = async () => {
  const payload: PeoplePayload = {
    people
  };

  return new Response(JSON.stringify(payload), {
    status: 200,
    headers: {
      'Content-Type': 'application/json'
    }
  });
};