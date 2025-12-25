<script lang="ts">
	import type { PersonDossier } from '$lib/schema';

	export let data: {
		people: PersonDossier[];
	};

	const people = data.people;
</script>

<svelte:head>
	<title>Manna · People</title>
	<meta name="robots" content="noindex,nofollow" />
</svelte:head>

<section class="shell">
	<header class="header">
		<div>
			<h1>People</h1>
			<p class="lead">
				Key people in your world as surfaced by Manna. Each one is a stewarded relationship, not a
				contact.
			</p>
		</div>
		<div class="count-pill">
			<span>{people.length}</span>
			<span>{people.length === 1 ? 'person' : 'people'}</span>
		</div>
	</header>

	{#if people.length === 0}
		<p class="hint">
			No people have been surfaced yet. Once captures are structured and linked, relationships will
			show here.
		</p>
	{:else}
		<ul class="grid">
			<!-- svelte-ignore svelte/require-each-key -->
			{#each people as person}
				<li class="card">
					<a class="card-link" href={`/people/${person.person_id}`}>
						<div class="card-header">
							<div>
								<h2>{person.name ?? person.person_id}</h2>
								{#if person.relationship}
									<p class="relationship">{person.relationship}</p>
								{/if}
							</div>
							{#if person.domains && person.domains.length}
								<div class="domain-pill">
									{person.domains.join(', ')}
								</div>
							{/if}
						</div>

						{#if person.snapshot}
							<p class="snapshot">{person.snapshot}</p>
						{:else if person.note}
							<p class="snapshot">{person.note}</p>
						{/if}

						<div class="meta-row">
							{#if person.first_seen_at}
								<span class="meta">First seen: {person.first_seen_at}</span>
							{/if}
							{#if person.last_seen_at}
								<span class="meta">Last seen: {person.last_seen_at}</span>
							{/if}
						</div>

						{#if person.tags && person.tags.length}
							<div class="tags">
								<!-- svelte-ignore svelte/require-each-key -->
								{#each person.tags.slice(0, 4) as tag}
									<span class="tag">{tag}</span>
								{/each}
								{#if person.tags.length > 4}
									<span class="tag extra">+{person.tags.length - 4}</span>
								{/if}
							</div>
						{/if}
					</a>
				</li>
			{/each}
		</ul>
	{/if}
</section>

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
		margin-bottom: 0.5rem;
	}

	.lead {
		margin: 0;
	}

	.count-pill {
		display: inline-flex;
		align-items: center;
		gap: 0.35rem;
		padding: 0.4rem 0.8rem;
		border-radius: 999px;
		border: 1px solid #1f2937;
		font-size: 0.85rem;
		background-color: #020617;
	}

	.grid {
		list-style: none;
		padding: 0;
		margin: 0;
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
		gap: 1rem;
	}

	.card {
		border-radius: 0.9rem;
		border: 1px solid #111827;
		background-color: #020617;
		overflow: hidden;
	}

	.card-link {
		display: block;
		padding: 0.9rem 1rem;
		text-decoration: none;
		color: inherit;
	}

	.card-header {
		display: flex;
		justify-content: space-between;
		gap: 0.75rem;
		align-items: baseline;
		margin-bottom: 0.5rem;
	}

	h2 {
		font-size: 1.1rem;
		margin: 0;
	}

	.relationship {
		margin: 0.1rem 0 0;
		font-size: 0.85rem;
		color: #9ca3af;
	}

	.domain-pill {
		font-size: 0.75rem;
		padding: 0.2rem 0.5rem;
		border-radius: 999px;
		border: 1px solid #1f2937;
		color: #e5e7eb;
		max-width: 10rem;
		text-align: right;
	}

	.snapshot {
		margin: 0.35rem 0;
		font-size: 0.9rem;
		color: #e5e7eb;
	}

	.meta-row {
		display: flex;
		flex-wrap: wrap;
		gap: 0.5rem;
		font-size: 0.8rem;
		color: #9ca3af;
	}

	.meta {
		opacity: 0.9;
	}

	.tags {
		margin-top: 0.5rem;
		display: flex;
		flex-wrap: wrap;
		gap: 0.35rem;
	}

	.tag {
		display: inline-block;
		padding: 0.05rem 0.45rem;
		border-radius: 999px;
		font-size: 0.75rem;
		background-color: #111827;
		color: #e5e7eb;
	}

	.tag.extra {
		opacity: 0.8;
	}

	.hint {
		margin: 0.35rem 0 0;
		font-size: 0.85rem;
		color: #9ca3af;
	}
</style>
