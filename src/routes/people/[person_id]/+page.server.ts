import type { PageServerLoad } from './$types';
import type { PeoplePayload, PersonDossier } from '$lib/schema';

export const load: PageServerLoad = async ({ params, fetch }) => {
  const { person_id } = params;

  let peoplePayload: PeoplePayload | null = null;

  try {
    const res = await fetch('/api/people');
    if (res.ok) {
      peoplePayload = (await res.json()) as PeoplePayload;
    }
  } catch {
    peoplePayload = null;
  }

  const people = peoplePayload?.people ?? [];
  const person = people.find((p) => p.person_id === person_id) ?? null;

  return {
    person: person as PersonDossier | null
  };
};