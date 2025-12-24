import adapter from '@sveltejs/adapter-vercel';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	preprocess: vitePreprocess(),
	kit: {
		adapter: adapter({
			// Tell the adapter explicitly which Node runtime to use on Vercel
			runtime: 'nodejs22.x'
		})
	}
};

export default config;
