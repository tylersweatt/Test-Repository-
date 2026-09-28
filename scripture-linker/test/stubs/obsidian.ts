// Just enough of Obsidian's API for the indexer to load under node.
export class Events {
	private handlers = new Map<string, ((...a: unknown[]) => void)[]>();
	on(name: string, cb: (...a: unknown[]) => void) {
		this.handlers.set(name, [...(this.handlers.get(name) ?? []), cb]);
	}
	trigger(name: string, ...args: unknown[]) {
		for (const cb of this.handlers.get(name) ?? []) cb(...args);
	}
}
export class TFile {
	constructor(public path: string, public extension = "md") {}
}
export class Vault {}
