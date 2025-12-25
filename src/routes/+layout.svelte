<script lang="ts">
	import Analytics from '$lib/Analytics.svelte';
</script>

<svelte:head>
	<title>Manna</title>
	<meta name="description" content="Manna – private Digital Brain prototype." />
	<meta name="robots" content="noindex, nofollow" />
</svelte:head>

<main class="app">
	<Analytics />
	<slot />
</main>

<style>
	:global(body) {
		margin: 0;
		font-family:
			system-ui,
			-apple-system,
			BlinkMacSystemFont,
			BlinkMacSystemFont,
			-apple-system,
			sans-serif;
		background-color: #020617;
		color: #e5e7eb;
	}

	.app {
		min-height: 100vh;
		display: flex;
		align-items: center;
		justify-content: center;
		padding: 2rem;
	}
</style>
