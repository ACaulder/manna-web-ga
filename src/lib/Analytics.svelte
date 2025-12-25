<script lang="ts">
	import { onMount } from 'svelte';
	import { afterNavigate } from '$app/navigation';
	import { browser } from '$app/environment';
	import { env } from '$env/dynamic/public';

	declare global {
		interface Window {
			dataLayer?: unknown[];
			gtag?: (...args: unknown[]) => void;
		}
	}

	function ensureGtag(id: string) {
		if (document.querySelector(`script[src*="gtag/js?id=${id}"]`)) return;

		window.dataLayer = window.dataLayer || [];
		window.gtag =
			window.gtag ||
			function (...args: unknown[]) {
				window.dataLayer?.push(args);
			};

		const s = document.createElement('script');
		s.async = true;
		s.src = `https://www.googletagmanager.com/gtag/js?id=${id}`;
		document.head.appendChild(s);

		window.gtag('js', new Date());
		window.gtag('config', id, { send_page_view: false });
	}

	function sendPageView(id: string, url: URL) {
		window.gtag?.('event', 'page_view', {
			page_location: url.href,
			page_path: url.pathname + url.search,
			page_title: document.title
		});
	}

	onMount(() => {
		if (!browser) return;
		if (!import.meta.env.PROD) return;

		const id = (env.PUBLIC_GA_MEASUREMENT_ID || '').trim();
		if (!id.startsWith('G-')) return;

		ensureGtag(id);
		sendPageView(id, new URL(window.location.href));

		afterNavigate((nav) => {
			if (!nav.to?.url) return;
			sendPageView(id, nav.to.url);
		});
	});
</script>
