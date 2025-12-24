import type { PageServerLoad } from './$types';
import type { PeoplePayload } from '$lib/schema';

export const load: PageServerLoad = async ({ fetch }) => {
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

  return {
    people
  };
};