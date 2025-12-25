import capturesRaw from '$lib/data/captures.json';

type Capture = {
	cluster_id?: string;
	clusterId?: string;
	cluster?: string;
	[k: string]: unknown;
};

const captures = capturesRaw as unknown as Capture[];

/**
 * CI/build unblocker.
 * Replace with real storage later. This exists so CI can compile.
 */
export function getDocsForCluster(clusterId: string): Capture[] {
	if (!clusterId) return [];
	return captures.filter((c) => {
		const v = c.cluster_id ?? c.clusterId ?? c.cluster;
		return typeof v === 'string' && v === clusterId;
	});
}
