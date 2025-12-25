<script lang="ts">
	import type { Capture, CaptureSummary } from '$lib/schema';

	export let data: {
		captures: Capture[];
		summary: CaptureSummary | null;
	};

	const captures = data.captures;
	const summary = data.summary;
</script>

<svelte:head>
	<title>Manna · Captures</title>
	<meta name="robots" content="noindex,nofollow" />
</svelte:head>

<section class="shell">
	<header class="header">
		<div>
			<h1>Captures</h1>
			<p class="lead">All structured Manna captures that are currently surfaced to the app.</p>
		</div>
		{#if summary}
			<div class="summary-pill">
				<span>Total: {summary.total}</span>
				<span>Captured: {summary.captured}</span>
				<span>Transcribed: {summary.transcribed}</span>
				<span>Structured: {summary.structured}</span>
				<span>Reviewed: {summary.reviewed}</span>
			</div>
		{/if}
	</header>

	{#if captures.length === 0}
		<p class="hint">
			No captures available yet. Once transcripts are structured into BE / KNOW / DO / FEEL,
			they&apos;ll show here.
		</p>
	{:else}
		<ul class="capture-list">
			<!-- svelte-ignore svelte/require-each-key -->
			{#each captures as capture, idx}
				<li class="capture-card">
					<div class="capture-headline">
						<div>
							<h2>{capture.title ?? capture.id}</h2>
							<p class="capture-date">{capture.date}</p>
						</div>
						<span class="index-pill">#{idx + 1}</span>
					</div>

					<div class="capture-grid">
						<div class="capture-column">
							<h3>Be</h3>
							{#if capture.be && capture.be.length}
								<p class="manna-title">{capture.be[0].statement}</p>
								{#if capture.be[0].practices && capture.be[0].practices.length}
									<ul class="mini-list">
										<!-- svelte-ignore svelte/require-each-key -->
										{#each capture.be[0].practices as p}
											<li>{p}</li>
										{/each}
									</ul>
								{/if}
							{:else}
								<p class="hint">No BE entry.</p>
							{/if}
						</div>

						<div class="capture-column">
							<h3>Know</h3>
							{#if capture.know && capture.know.length}
								<p class="manna-title">{capture.know[0].truth}</p>
								{#if capture.know[0].lie}
									<p class="hint">Lie it confronts: {capture.know[0].lie}</p>
								{/if}
							{:else}
								<p class="hint">No KNOW entry.</p>
							{/if}
						</div>

						<div class="capture-column">
							<h3>Do</h3>
							{#if capture.do && capture.do.length}
								<p class="manna-title">{capture.do[0].action}</p>
								{#if capture.do[0].due}
									<p class="hint">Due: <code>{capture.do[0].due}</code></p>
								{/if}
							{:else}
								<p class="hint">No DO entry.</p>
							{/if}
						</div>

						<div class="capture-column">
							<h3>Feel</h3>
							{#if capture.feel && capture.feel.length}
								<p class="manna-title">{capture.feel[0].current_emotion}</p>
								{#if capture.feel[0].desired_direction}
									<p class="hint">
										Desired direction: {capture.feel[0].desired_direction}
									</p>
								{/if}
							{:else}
								<p class="hint">No FEEL entry.</p>
							{/if}
						</div>
					</div>

					{#if capture.people && capture.people.length}
						<div class="people-block">
							<h3>People surfaced</h3>
							<ul class="people-list">
								<!-- svelte-ignore svelte/require-each-key -->
								{#each capture.people as person}
									<li>
										<strong>{person.name ?? person.person_id}</strong>
										{#if person.relationship}
											<span class="tag">{person.relationship}</span>
										{/if}
										{#if person.domains && person.domains.length}
											<span class="tag tag-domain">{person.domains.join(', ')}</span>
										{/if}
										{#if person.note}
											<p class="hint">{person.note}</p>
										{/if}
									</li>
								{/each}
							</ul>
						</div>
					{/if}
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

	h2 {
		font-size: 1.1rem;
		margin: 0;
	}

	h3 {
		font-size: 0.95rem;
		margin: 0 0 0.3rem;
	}

	.lead {
		margin: 0;
	}

	.summary-pill {
		display: flex;
		flex-wrap: wrap;
		gap: 0.5rem;
		font-size: 0.8rem;
		padding: 0.5rem 0.75rem;
		border-radius: 999px;
		border: 1px solid #1f2937;
		background-color: #020617;
	}

	.capture-list {
		list-style: none;
		padding: 0;
		margin: 0;
		display: grid;
		gap: 1rem;
	}

	.capture-card {
		padding: 1rem 1.1rem;
		border-radius: 0.9rem;
		border: 1px solid #111827;
		background-color: #020617;
	}

	.capture-headline {
		display: flex;
		justify-content: space-between;
		align-items: baseline;
		gap: 0.75rem;
		margin-bottom: 0.75rem;
	}

	.capture-date {
		margin: 0.1rem 0 0;
		font-size: 0.85rem;
		color: #9ca3af;
	}

	.index-pill {
		font-size: 0.75rem;
		padding: 0.2rem 0.6rem;
		border-radius: 999px;
		border: 1px solid #1f2937;
		color: #e5e7eb;
	}

	.capture-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
		gap: 0.75rem;
		margin-bottom: 0.75rem;
	}

	.capture-column {
		padding: 0.6rem 0.7rem;
		border-radius: 0.6rem;
		border: 1px solid #111827;
		background-color: #020617;
	}

	.manna-title {
		margin: 0.15rem 0 0.2rem;
	}

	.mini-list {
		margin: 0.25rem 0 0;
		padding-left: 1.1rem;
		font-size: 0.85rem;
	}

	.people-block {
		margin-top: 0.75rem;
	}

	.people-list {
		list-style: none;
		padding: 0;
		margin: 0.4rem 0 0;
		display: grid;
		gap: 0.4rem;
	}

	.people-list li {
		padding: 0.35rem 0;
		border-top: 1px solid #111827;
	}

	.people-list li:last-child {
		border-bottom: 1px solid #111827;
	}

	.tag {
		display: inline-block;
		margin-left: 0.35rem;
		padding: 0.05rem 0.4rem;
		border-radius: 999px;
		font-size: 0.75rem;
		background-color: #111827;
		color: #e5e7eb;
	}

	.tag-domain {
		opacity: 0.85;
	}

	.hint {
		margin: 0.25rem 0 0;
		font-size: 0.85rem;
		color: #9ca3af;
	}
</style>
