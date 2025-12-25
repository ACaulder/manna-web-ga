<script lang="ts">
	import type { Capture } from '$lib/schema';

	type Ping = { status: string; env: string; timestamp: string } | null;

	type CapturesPayload = {
		captures: Capture[];
		summary: {
			total: number;
			captured: number;
			transcribed: number;
			structured: number;
			reviewed: number;
		};
	} | null;

	export let data: {
		origin: string;
		ping: Ping;
		captures: CapturesPayload;
	};

	const origin = data.origin;
	const ping = data.ping;
	const capturesPayload = data.captures;
	const captures = capturesPayload?.captures ?? [];
	const summary = capturesPayload?.summary ?? null;

	const latestCapture = captures[captures.length - 1] ?? null;

	const todayBe = latestCapture?.be[0] ?? null;
	const todayKnow = latestCapture?.know[0] ?? null;
	const todayDo = latestCapture?.do[0] ?? null;
	const todayFeel = latestCapture?.feel[0] ?? null;

	const todayPeople = latestCapture?.people ?? [];
</script>

<svelte:head>
	<title>Manna · Home</title>
	<meta name="robots" content="noindex,nofollow" />
</svelte:head>

<section class="shell">
	<h1>Manna</h1>
	<p class="lead">A private space to prototype your Digital Brain.</p>
	<p class="lead">
		Below are today&apos;s portion from your captures, your calendar feeds, and system status.
	</p>

	<div class="section">
		<h2>Today&apos;s Manna (from captures)</h2>

		{#if latestCapture}
			<div class="manna-grid">
				<div class="manna-card">
					<h3>Be</h3>
					{#if todayBe}
						<p class="manna-title">{todayBe.statement}</p>
						{#if todayBe.practices && todayBe.practices.length}
							<ul class="mini-list">
								<!-- svelte-ignore svelte/require-each-key -->
								{#each todayBe.practices as p}
									<li>{p}</li>
								{/each}
							</ul>
						{/if}
					{:else}
						<p class="hint">No BE items found in the latest capture.</p>
					{/if}
				</div>

				<div class="manna-card">
					<h3>Know</h3>
					{#if todayKnow}
						<p class="manna-title">{todayKnow.truth}</p>
						{#if todayKnow.lie}
							<p class="hint">Lie it confronts: {todayKnow.lie}</p>
						{/if}
					{:else}
						<p class="hint">No KNOW items found in the latest capture.</p>
					{/if}
				</div>

				<div class="manna-card">
					<h3>Do</h3>
					{#if todayDo}
						<p class="manna-title">{todayDo.action}</p>
						{#if todayDo.due}
							<p class="hint">Due: <code>{todayDo.due}</code></p>
						{/if}
					{:else}
						<p class="hint">No DO items found in the latest capture.</p>
					{/if}
				</div>

				<div class="manna-card">
					<h3>Feel</h3>
					{#if todayFeel}
						<p class="manna-title">{todayFeel.current_emotion}</p>
						{#if todayFeel.desired_direction}
							<p class="hint">
								Desired direction: {todayFeel.desired_direction}
							</p>
						{/if}
					{:else}
						<p class="hint">No FEEL items found in the latest capture.</p>
					{/if}
				</div>
			</div>

			<div class="subsection">
				<h3>People surfaced</h3>
				{#if todayPeople.length}
					<ul class="people-list">
						<!-- svelte-ignore svelte/require-each-key -->
						{#each todayPeople as person, idx}
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
				{:else}
					<p class="hint">No people attached to the latest capture.</p>
				{/if}
			</div>
		{:else}
			<p class="hint">
				No captures found yet. Once you start processing voice notes into captures, today&apos;s BE
				/ KNOW / DO / FEEL will show up here.
			</p>
		{/if}
	</div>

	<div class="section">
		<h2>Capture pipeline</h2>
		{#if summary}
			<p class="hint">
				Total: {summary.total} · Captured: {summary.captured} · Transcribed: {summary.transcribed} ·
				Structured: {summary.structured} · Reviewed: {summary.reviewed}
			</p>
		{:else}
			<p class="hint">
				No capture summary available. Check that <code>/api/captures</code> is returning data.
			</p>
		{/if}
	</div>

	<div class="section">
		<h2>Calendar feeds</h2>
		<ul>
			<li>
				<strong>Prayer Rhythm</strong>
				<div class="url">
					<code>{origin}/prayer.ics</code>
				</div>
				<p class="hint">
					Daily prayer anchor. Subscribe in Apple Calendar, Google Calendar, or any app that
					supports .ics URLs.
				</p>
			</li>
			<li>
				<strong>Reachout Rhythm</strong>
				<div class="url">
					<code>{origin}/reachout.ics</code>
				</div>
				<p class="hint">Weekly relational prompts on Monday, Wednesday, and Friday.</p>
			</li>
		</ul>
	</div>

	<div class="section">
		<h2>System status</h2>
		{#if ping}
			<p class="status-line">
				<span class="status-dot {ping.status === 'ok' ? 'ok' : 'warn'}"></span>
				<span class="status-text">
					{ping.status === 'ok' ? 'Online' : ping.status}
					<span class="env">({ping.env})</span>
				</span>
			</p>
			<p class="hint">
				Last health check: <code>{ping.timestamp}</code>
			</p>
			<p class="hint">
				Raw endpoint: <code>{origin}/api/ping</code>
			</p>
		{:else}
			<p class="hint">
				Status check unavailable. If this persists, verify that <code>/api/ping</code> is reachable.
			</p>
		{/if}
	</div>

	<p class="footnote">
		Manna is online but hidden from search. Anyone you share these URLs with can subscribe, but
		crawlers are told to stay out.
	</p>
</section>

<style>
	.shell {
		max-width: 44rem;
		padding: 2.25rem 2.75rem;
		border-radius: 1.25rem;
		background-color: #020617;
		border: 1px solid #1f2937;
		box-shadow: 0 24px 60px rgba(0, 0, 0, 0.65);
	}

	h1 {
		font-size: 2.1rem;
		margin-bottom: 0.75rem;
	}

	h2 {
		font-size: 1.1rem;
		margin: 1.5rem 0 0.75rem;
	}

	h3 {
		font-size: 1rem;
		margin: 0 0 0.35rem;
	}

	.lead {
		margin: 0.25rem 0;
	}

	.section {
		margin-top: 1.5rem;
	}

	.subsection {
		margin-top: 1rem;
	}

	.manna-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
		gap: 0.75rem;
	}

	.manna-card {
		padding: 0.85rem 1rem;
		border-radius: 0.75rem;
		background-color: #020617;
		border: 1px solid #1f2937;
	}

	.manna-title {
		margin: 0.2rem 0 0.2rem;
	}

	.mini-list {
		margin: 0.25rem 0 0;
		padding-left: 1.1rem;
		font-size: 0.85rem;
	}

	.people-list {
		list-style: none;
		padding: 0;
		margin: 0;
		display: grid;
		gap: 0.5rem;
	}

	.people-list li {
		padding: 0.5rem 0;
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

	ul {
		list-style: none;
		padding: 0;
		margin: 0;
		display: grid;
		gap: 1rem;
	}

	li {
		padding: 0.75rem 0;
		border-top: 1px solid #111827;
	}

	li:last-child {
		border-bottom: 1px solid #111827;
	}

	.url {
		margin-top: 0.25rem;
	}

	code {
		font-family:
			ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New',
			monospace;
		font-size: 0.85rem;
		padding: 0.15rem 0.35rem;
		border-radius: 0.35rem;
		background-color: #020617;
		border: 1px solid #1f2937;
	}

	.hint {
		margin: 0.35rem 0 0;
		font-size: 0.85rem;
		color: #9ca3af;
	}

	.status-line {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		margin: 0.25rem 0;
	}

	.status-dot {
		width: 0.6rem;
		height: 0.6rem;
		border-radius: 999px;
		background-color: #f97316;
	}

	.status-dot.ok {
		background-color: #22c55e;
	}

	.status-text {
		font-size: 0.95rem;
	}

	.env {
		margin-left: 0.25rem;
		font-size: 0.8rem;
		color: #9ca3af;
	}

	.footnote {
		margin-top: 1.5rem;
		font-size: 0.8rem;
		color: #6b7280;
	}
</style>
