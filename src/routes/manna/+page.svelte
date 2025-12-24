<script lang="ts">
  export let data;

  type Cluster = {
    id: number | string;
    words: string[];
    size: number;
  };

  type Doc = {
    id: string;
    timestamp: string;
    snippet: string;
  };

  const clusters: Cluster[] = data.clusters ?? [];

  let selectedCluster: Cluster | null = null;
  let docs: Doc[] = [];
  let loading = false;
  let error: string | null = null;

  async function handleSelect(cluster: Cluster) {
    selectedCluster = cluster;
    loading = true;
    error = null;
    docs = [];

    try {
      // This API endpoint can be implemented later; for now this wiring is correct.
      const res = await fetch(`/api/manna/cluster/${cluster.id}`);
      if (!res.ok) throw new Error(`Failed to load docs for cluster ${cluster.id}`);
      docs = await res.json();
    } catch (e: any) {
      console.error(e);
      error = e.message ?? 'Something went wrong loading docs.';
    } finally {
      loading = false;
    }
  }
</script>

<div class="layout">
  <aside class="topics">
    <h1>Topics</h1>
    <p>loaded {clusters.length} clusters</p>

    {#if clusters.length === 0}
      <p style="margin-top: 1rem; opacity: 0.7;">
        No clusters returned from the worker. Check the /topics payload and mapping.
      </p>
    {/if}

    {#each clusters as cluster}
      <button
        class={`topic-button ${selectedCluster?.id === cluster.id ? 'selected' : ''}`}
        on:click={() => handleSelect(cluster)}
      >
        <div class="topic-header">
          <span>#{cluster.id}</span>
          <span>{cluster.size} docs</span>
        </div>
        <div class="topic-words">
          {cluster.words.join(' · ')}
        </div>
      </button>
    {/each}
  </aside>

  <main class="details">
    {#if !selectedCluster}
      <p>Choose a topic on the left.</p>
    {:else}
      <h2>Cluster #{selectedCluster.id}</h2>
      <p class="topic-words">{selectedCluster.words.join(' · ')}</p>

      {#if loading}
        <p>Loading docs…</p>
      {:else if error}
        <p class="error">{error}</p>
      {:else if docs.length === 0}
        <p>No docs found for this cluster.</p>
      {:else}
        <ul class="doc-list">
          {#each docs as doc}
            <li>
              <div class="doc-meta">{doc.timestamp}</div>
              <div class="doc-snippet">{doc.snippet}</div>
            </li>
          {/each}
        </ul>
      {/if}
    {/if}
  </main>
</div>

<style>
  .layout {
    display: grid;
    grid-template-columns: 320px minmax(0, 1fr);
    gap: 2rem;
    padding: 2rem 4rem;
  }
  .topics {
    font-size: 0.9rem;
  }
  .topic-button {
    display: block;
    width: 100%;
    text-align: left;
    margin-bottom: 0.5rem;
    padding: 0.5rem 0.75rem;
    border-radius: 0.375rem;
    border: 1px solid #444;
    background: transparent;
    cursor: pointer;
  }
  .topic-button.selected {
    border-color: #fff;
    background: #222;
  }
  .topic-header {
    display: flex;
    gap: 0.5rem;
    font-weight: 600;
  }
  .topic-words {
    font-size: 0.75rem;
    opacity: 0.8;
  }
  .details {
    font-size: 0.9rem;
  }
  .doc-list {
    list-style: none;
    padding: 0;
    margin: 1rem 0 0;
  }
  .doc-list li {
    margin-bottom: 1rem;
    border-bottom: 1px solid #333;
    padding-bottom: 0.75rem;
  }
  .doc-meta {
    font-size: 0.7rem;
    opacity: 0.7;
    margin-bottom: 0.25rem;
  }
  .doc-snippet {
    font-size: 0.85rem;
  }
  .error {
    color: #f66;
  }
</style>