<script lang="ts">
	export let data;

	const people = data.people as {
		name: string;
		roles: string[];
		appearances: number;
		importanceScore: number;
		files: string[];
		commitments: any[];
		relationships: any[];
		tags: string[];
	}[];

	const openCommitments = data.openCommitments as {
		owner: string;
		action: string;
		context: string;
		deadline: string | null;
		status: string;
		source_quote: string;
	}[];

	const fileCount = data.fileCount as number;
</script>

<section class="p-6 space-y-8">
	<header class="space-y-2">
		<h1 class="text-3xl font-bold tracking-tight">Relational Radar</h1>
		<p class="text-sm text-neutral-400">
			Manna PE V2 · {fileCount} transcript{fileCount === 1 ? '' : 's'} indexed
		</p>
	</header>

	<div class="grid gap-8 lg:grid-cols-2">
		<!-- People focus -->
		<div class="rounded-2xl border border-neutral-800 bg-neutral-950/60 p-4 space-y-4">
			<div class="flex items-center justify-between">
				<h2 class="text-lg font-semibold">People in focus</h2>
				<span class="text-xs text-neutral-400"> Sorted by importance & appearances </span>
			</div>

			{#if people.length === 0}
				<p class="text-sm text-neutral-500">
					No people indexed yet. Once your insights run, they’ll show up here.
				</p>
			{:else}
				<div class="space-y-2 max-h-[28rem] overflow-auto pr-1">
					{#each people as person}
						<div
							class="flex items-start justify-between rounded-xl border border-neutral-800/80 bg-neutral-900/60 px-3 py-2"
						>
							<div class="space-y-1">
								<div class="flex items-center gap-2">
									<span class="font-semibold">{person.name}</span>
									{#if person.roles.length > 0}
										<span class="text-[0.7rem] uppercase tracking-wide text-neutral-400">
											{person.roles.join(' · ')}
										</span>
									{/if}
								</div>
								<div class="text-xs text-neutral-400">
									{person.appearances} appearance{person.appearances === 1 ? '' : 's'}
									· importance score {person.importanceScore}
								</div>
								{#if person.commitments.length > 0}
									<div class="text-xs text-amber-300">
										{person.commitments.length} open commitment{person.commitments.length === 1
											? ''
											: 's'}
									</div>
								{/if}
							</div>

							<div class="flex flex-col items-end gap-1">
								{#if person.commitments.length > 0}
									<span
										class="rounded-full bg-amber-500/10 px-2 py-0.5 text-[0.7rem] text-amber-300"
									>
										Needs attention
									</span>
								{/if}
								<span class="text-[0.7rem] text-neutral-500">
									{person.files.length} file{person.files.length === 1 ? '' : 's'}
								</span>
							</div>
						</div>
					{/each}
				</div>
			{/if}
		</div>

		<!-- Commitments -->
		<div class="rounded-2xl border border-neutral-800 bg-neutral-950/60 p-4 space-y-4">
			<div class="flex items-center justify-between">
				<h2 class="text-lg font-semibold">Open commitments</h2>
				<span class="text-xs text-neutral-400"> Pulled from your transcripts </span>
			</div>

			{#if openCommitments.length === 0}
				<p class="text-sm text-neutral-500">
					No open commitments detected yet. Once you start capturing decisions and plans in audio,
					they’ll be extracted here.
				</p>
			{:else}
				<div class="space-y-2 max-h-[28rem] overflow-auto pr-1">
					{#each openCommitments as c}
						<article
							class="rounded-xl border border-neutral-800/80 bg-neutral-900/60 px-3 py-2 space-y-1"
						>
							<div class="flex items-center justify-between gap-2">
								<div class="text-sm font-medium">
									{c.action}
								</div>
								<span
									class="text-[0.7rem] rounded-full bg-neutral-800 px-2 py-0.5 text-neutral-300"
								>
									{c.owner}
								</span>
							</div>
							{#if c.context}
								<div class="text-xs text-neutral-400">
									{c.context}
								</div>
							{/if}
							<div class="flex items-center justify-between text-[0.7rem] text-neutral-500">
								<span>
									Status: {c.status || 'open'}
								</span>
								<span>
									{#if c.deadline}
										Deadline: {c.deadline}
									{:else}
										No explicit deadline
									{/if}
								</span>
							</div>
						</article>
					{/each}
				</div>
			{/if}
		</div>
	</div>
</section>
