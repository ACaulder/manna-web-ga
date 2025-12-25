#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

mkdir -p src/lib

cat > src/lib/Analytics.svelte <<'SVELTE'
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
SVELTE

python3 - <<'PY'
from pathlib import Path

p = Path("src/routes/+layout.svelte")
p.parent.mkdir(parents=True, exist_ok=True)

if not p.exists():
    p.write_text(
        "<script lang=\"ts\">\n"
        "  import Analytics from '$lib/Analytics.svelte';\n"
        "</script>\n\n"
        "<Analytics />\n"
        "<slot />\n"
    )
    print("Created src/routes/+layout.svelte with <Analytics />")
    raise SystemExit(0)

s = p.read_text()

if "Analytics from '$lib/Analytics.svelte'" not in s:
    if "<script" in s:
        lines = s.splitlines(True)
        for i, line in enumerate(lines):
            if line.lstrip().startswith("<script"):
                lines.insert(i + 1, "  import Analytics from '$lib/Analytics.svelte';\n")
                s = "".join(lines)
                break
    else:
        s = (
            "<script lang=\"ts\">\n"
            "  import Analytics from '$lib/Analytics.svelte';\n"
            "</script>\n\n" + s
        )

if "<Analytics" not in s:
    if "<slot" in s:
        s = s.replace("<slot", "<Analytics />\n<slot", 1)
    else:
        s = s + "\n<Analytics />\n"

p.write_text(s)
print("Patched src/routes/+layout.svelte to include <Analytics />")
PY

echo "Wired GA: src/lib/Analytics.svelte + layout patch complete."
