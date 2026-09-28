import { requestUrl } from "obsidian";

export interface Passage {
	reference: string;
	text: string;
	fetchedAt: number;
}

// The ESV API terms cap how much text an app may store locally, so the cache
// stays small and drops the oldest passages first.
const MAX_CACHED = 100;

export class EsvClient {
	private inflight = new Map<string, Promise<Passage>>();

	constructor(
		private getKey: () => string,
		private cache: Record<string, Passage>,
		private persist: () => void,
	) {}

	get hasKey(): boolean {
		return this.getKey().trim().length > 0;
	}

	async fetch(query: string): Promise<Passage> {
		const hit = this.cache[query];
		if (hit) return hit;
		const pending = this.inflight.get(query);
		if (pending) return pending;

		const p = this.request(query).finally(() => this.inflight.delete(query));
		this.inflight.set(query, p);
		return p;
	}

	private async request(query: string): Promise<Passage> {
		const params = new URLSearchParams({
			q: query,
			"include-passage-references": "false",
			"include-verse-numbers": "true",
			"include-first-verse-numbers": "false",
			"include-footnotes": "false",
			"include-headings": "false",
			"include-short-copyright": "false",
			"include-selahs": "true",
			"indent-poetry": "true",
		});
		const res = await requestUrl({
			url: `https://api.esv.org/v3/passage/text/?${params}`,
			headers: { Authorization: `Token ${this.getKey().trim()}` },
			throw: false,
		});
		if (res.status === 401 || res.status === 403) {
			throw new Error("The ESV API key was rejected. Check it in the Scripture Linker settings.");
		}
		if (res.status !== 200) throw new Error(`ESV API returned ${res.status}.`);

		const body = res.json as { canonical?: string; passages?: string[] };
		const text = (body.passages ?? []).join("\n\n").trim();
		if (!text) throw new Error("No passage found.");

		const passage = { reference: body.canonical ?? query, text, fetchedAt: Date.now() };
		this.cache[query] = passage;
		this.trim();
		this.persist();
		return passage;
	}

	private trim() {
		const keys = Object.keys(this.cache);
		if (keys.length <= MAX_CACHED) return;
		keys.sort((a, b) => this.cache[a].fetchedAt - this.cache[b].fetchedAt);
		for (const k of keys.slice(0, keys.length - MAX_CACHED)) delete this.cache[k];
	}

	clear() {
		for (const k of Object.keys(this.cache)) delete this.cache[k];
		this.persist();
	}
}
