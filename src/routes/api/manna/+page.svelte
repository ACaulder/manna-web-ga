<script lang="ts">
	import { onMount } from 'svelte';

	const API_BASE = '/api';
	const SUMMARY_DIR = '/Users/andrewcaulder/MannaWorker/var/summaries';

	type TopicData = { keywords: string[]; size: number; docs: string[] };
	type Topics = Record<number, TopicData>;
	type Cluster = { id: number; keywords: string[]; size: number; docs: string[] };

	let topics: Topics = {};
	let clusters: Cluster[] = [];
	let selectedCluster: Cluster | null = null;

	let selectedDoc: string | null = null;
	let summary = '';
	let loading = false;
	let err = '';
	let filter = '';

	// helpers
	const stem = (p: string) => p.split('/').pop() ?? p;
	const fmtDoc = (p: string) => stem(p).replace(/\.json$/, '');
	const kws = (arr?: string[]) => (arr ?? []).slice(0, 8);

	async function loadTopics() {
		err = '';
		try {
			const res = await fetch(`${API_BASE}/topics`);
			if (!res.ok) throw new Error(`topics ${res.status}`);
			const raw: Record<string, TopicData> = await res.json();

			topics = Object.fromEntries(Object.entries(raw).map(([k, v]) => [Number(k), v])) as Topics;
			clusters = Object.entries(raw)
				.map(([id, v]) => ({ id: Number(id), ...v }))
				.sort((a, b) => b.size - a.size);

			// auto-select largest cluster if nothing selected
			if (!selectedCluster && clusters.length) selectedCluster = clusters[0];
		} catch (e: any) {
			console.error(e);
			err = e?.message ?? 'load failed';
		}
	}

	onMount(loadTopics);

	async function openDoc(path: string) {
		loading = true;
		summary = '';
		selectedDoc = path;
		try {
			const stem =
				path
					.split('/')
					.pop()
					?.replace(/\.json$/, '') ?? '';
			const mdPath = `${SUMMARY_DIR}/${stem}.md`;
			const resp = await fetch(`${API_BASE}/files?path=${encodeURIComponent(mdPath)}`);
			summary = resp.ok ? await resp.text() : '_summary not found_';
		} catch (e) {
			console.error(e);
			summary = '_summary not found_';
		} finally {
			loading = false;
		}
	}

	// reactive filtered docs for current cluster
	$: filteredDocs = selectedCluster
		? selectedCluster.docs.filter((d) => d.toLowerCase().includes(filter.toLowerCase()))
		: [];
</script>

<div class="grid grid-cols-12 gap-6 p-8 min-h-screen">
	<aside class="col-span-4 space-y-4 sticky top-0 self-start">
		<div class="flex items-center justify-between">
			<h2 class="text-xl font-semibold">Topics</h2>
			<button class="px-3 py-1 rounded bg-zinc-800 hover:bg-zinc-700" on:click={loadTopics}
				>Reload</button
			>
		</div>

		{#if err}
			<div class="text-red-400 text-sm">{err}</div>
		{/if}

		{#each clusters as c (c.id)}
			<button
				class="w-full text-left rounded border border-zinc-700/60 p-3 hover:bg-zinc-900/40 {selectedCluster?.id ===
				c.id
					? 'ring-2 ring-emerald-500/40 bg-zinc-900/60'
					: ''}"
				on:click={() => {
					selectedCluster = c;
					selectedDoc = null;
					summary = '';
					filter = '';
				}}
			>
				<div class="flex items-center gap-2">
					<span class="font-medium">#{c.id}</span>
					<span class="text-xs px-2 py-0.5 rounded bg-zinc-800">{c.size} docs</span>
				</div>
				<div class="mt-2 flex flex-wrap gap-1 text-xs opacity-80">
					{#each kws(c.keywords) as k (k)}
						<span class="px-1.5 py-0.5 rounded bg-zinc-800/70">{k}</span>
					{/each}
					{#if !c.keywords?.length}
						<span class="opacity-60">No keywords</span>
					{/if}
				</div>
			</button>
		{/each}
	</aside>

	<main class="col-span-8 space-y-4">
		{#if selectedCluster}
			<div class="flex items-center justify-between">
				<h2 class="text-xl font-semibold">
					Cluster #{selectedCluster.id} · {selectedCluster.size} docs
				</h2>
				<input
					class="px-3 py-1.5 rounded border border-zinc-700 bg-zinc-900 w-64"
					placeholder="Filter docs…"
					bind:value={filter}
				/>
			</div>

			<div class="grid gap-2">
				{#each filteredDocs as d (d)}
					<button
						class="text-left border border-zinc-700/60 rounded p-2 hover:bg-zinc-900/40"
						on:click={() => openDoc(d)}
						title={d}
					>
						{fmtDoc(d)}
					</button>
				{/each}
				{#if selectedCluster.docs.length && !filteredDocs.length}
					<div class="opacity-60 text-sm">No docs match “{filter}”.</div>
				{/if}
			</div>
		{:else}
			<div class="opacity-60">Choose a topic on the left.</div>
		{/if}

		{#if selectedDoc}
			<h3 class="mt-4 text-lg font-semibold">Summary</h3>
			{#if loading}
				<div class="opacity-60">Loading…</div>
			{:else}
				<pre
					class="whitespace-pre-wrap text-sm border border-zinc-700/60 rounded p-3">{summary}</pre>
			{/if}
		{/if}
	</main>
</div>

<style>
	.grid {
		font-family:
			ui-sans-serif,
			system-ui,
			-apple-system,
			Segoe UI,
			Roboto,
			sans-serif;
	}
</style>
