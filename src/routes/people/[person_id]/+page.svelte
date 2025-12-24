<script lang="ts">
  import type { PersonDossier } from '$lib/schema';

  export let data: {
    person: PersonDossier | null;
  };

  const person = data.person;
</script>

<svelte:head>
  <title>Manna · {person ? (person.name ?? person.person_id) : 'Person'}</title>
  <meta name="robots" content="noindex,nofollow" />
</svelte:head>

{#if !person}
  <section class="shell">
    <h1>Person not found</h1>
    <p class="hint">
      This person is not yet surfaced in Manna. They may have no structured captures attached yet.
    </p>
    <p class="hint">
      Return to <a href="/people">People</a>.
    </p>
  </section>
{:else}
  <section class="shell">
    <header class="header">
      <div>
        <h1>{person.name ?? person.person_id}</h1>
        {#if person.relationship}
          <p class="relationship">{person.relationship}</p>
        {/if}
        {#if person.domains && person.domains.length}
          <p class="domains">Domains: {person.domains.join(', ')}</p>
        {/if}
      </div>
      {#if person.next_reachout_date}
        <div class="reachout-pill">
          <span>Next reachout</span>
          <span class="date">{person.next_reachout_date}</span>
        </div>
      {/if}
    </header>

    <div class="grid">
      <section class="block">
        <h2>Snapshot</h2>
        {#if person.snapshot}
          <p>{person.snapshot}</p>
        {:else if person.note}
          <p>{person.note}</p>
        {:else}
          <p class="hint">No snapshot yet. Future structuring will summarize their current season.</p>
        {/if}

        {#if person.roles && person.roles.length}
          <h3>Roles</h3>
          <ul class="mini-list">
            <!-- svelte-ignore svelte/require-each-key -->
            {#each person.roles as role}
              <li>{role}</li>
            {/each}
          </ul>
        {/if}

        {#if person.tags && person.tags.length}
          <h3>Tags</h3>
          <div class="tags">
            <!-- svelte-ignore svelte/require-each-key -->
            {#each person.tags as tag}
              <span class="tag">{tag}</span>
            {/each}
          </div>
        {/if}
      </section>

      <section class="block">
        <h2>Story</h2>
        {#if person.story}
          <p>{person.story}</p>
        {:else}
          <p class="hint">
            No story written yet. As captures accumulate, this section can hold a narrative summary of their journey with you.
          </p>
        {/if}

        <div class="dates">
          {#if person.first_seen_at}
            <span class="meta">First seen: {person.first_seen_at}</span>
          {/if}
          {#if person.last_seen_at}
            <span class="meta">Last seen: {person.last_seen_at}</span>
          {/if}
          {#if person.capture_ids && person.capture_ids.length}
            <span class="meta">Captures: {person.capture_ids.length}</span>
          {/if}
        </div>
      </section>

      <section class="block">
        <h2>Prayer & Care</h2>
        {#if person.prayer_focus}
          <h3>Prayer focus</h3>
          <p>{person.prayer_focus}</p>
        {/if}

        {#if person.current_needs && person.current_needs.length}
          <h3>Current needs</h3>
          <ul class="mini-list">
            <!-- svelte-ignore svelte/require-each-key -->
            {#each person.current_needs as need}
              <li>{need}</li>
            {/each}
          </ul>
        {:else if !person.prayer_focus}
          <p class="hint">
            No current needs recorded. Future structuring can pull these from captures where you talk about them.
          </p>
        {/if}
      </section>
    </div>

    <footer class="footer">
      <p class="hint">
        This dossier is a living summary. It will deepen as Manna links more captures, prayers, and decisions to
        {person.name ?? person.person_id}.
      </p>
      <p class="hint">
        Return to <a href="/people">People</a>.
      </p>
    </footer>
  </section>
{/if}

<style>
  .shell {
    max-width: 64rem;
    padding: 2.25rem 2.75rem;
    border-radius: 1.25rem;
    background-color: #020617;
    border: 1px solid #1f2937;
    box-shadow: 0 24px 60px rgba(0, 0, 0, 0.65);
  }

  .header {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    gap: 1rem;
    align-items: flex-start;
    margin-bottom: 1.5rem;
  }

  h1 {
    font-size: 2rem;
    margin-bottom: 0.25rem;
  }

  .relationship {
    margin: 0.1rem 0;
    font-size: 0.9rem;
    color: #9ca3af;
  }

  .domains {
    margin: 0.1rem 0 0;
    font-size: 0.85rem;
    color: #9ca3af;
  }

  .reachout-pill {
    display: inline-flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 0.15rem;
    padding: 0.45rem 0.8rem;
    border-radius: 0.75rem;
    border: 1px solid #1f2937;
    font-size: 0.8rem;
    background-color: #020617;
  }

  .reachout-pill .date {
    font-weight: 500;
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 1rem;
    margin-bottom: 1rem;
  }

  .block {
    padding: 0.9rem 1rem;
    border-radius: 0.9rem;
    border: 1px solid #111827;
    background-color: #020617;
  }

  h2 {
    font-size: 1.1rem;
    margin: 0 0 0.35rem;
  }

  h3 {
    font-size: 0.95rem;
    margin: 0.7rem 0 0.25rem;
  }

  .tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.35rem;
    margin-top: 0.15rem;
  }

  .tag {
    display: inline-block;
    padding: 0.05rem 0.45rem;
    border-radius: 999px;
    font-size: 0.75rem;
    background-color: #111827;
    color: #e5e7eb;
  }

  .mini-list {
    margin: 0.15rem 0 0;
    padding-left: 1.1rem;
    font-size: 0.85rem;
  }

  .dates {
    margin-top: 0.75rem;
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    font-size: 0.8rem;
    color: #9ca3af;
  }

  .meta {
    opacity: 0.9;
  }

  .footer {
    margin-top: 0.75rem;
  }

  .hint {
    margin: 0.25rem 0 0;
    font-size: 0.85rem;
    color: #9ca3af;
  }

  a {
    color: #93c5fd;
  }
</style>