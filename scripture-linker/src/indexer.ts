import { Events, TFile, Vault } from "obsidian";
import { chaptersOf, findReferences, formatRef, maskCode, ScriptureRef } from "./parser";

export interface Occurrence {
	path: string;
	line: number;
	label: string;
	snippet: string;
	ref: ScriptureRef;
}

/** "Romans|8" */
export const chapterKey = (book: string, chapter: number) => `${book}|${chapter}`;

/**
 * Keeps a map of every Scripture reference in the vault, rebuilt per file as
 * notes change. Fires "changed" so the side panel can re-render.
 */
export class ScriptureIndex extends Events {
	private byFile = new Map<string, Occurrence[]>();
	ready = false;

	constructor(private vault: Vault, private isExcluded: (path: string) => boolean) {
		super();
	}

	async rebuild() {
		this.byFile.clear();
		const files = this.vault.getMarkdownFiles().filter((f) => !this.isExcluded(f.path));
		// Read in small batches so a large vault doesn't stall startup.
		for (let i = 0; i < files.length; i += 50) {
			await Promise.all(files.slice(i, i + 50).map((f) => this.scan(f)));
		}
		this.ready = true;
		this.trigger("changed");
	}

	/** Called with the note's fresh contents whenever Obsidian re-parses it. */
	update(file: TFile, text: string) {
		if (file.extension !== "md") return;
		if (this.isExcluded(file.path)) {
			if (this.byFile.delete(file.path)) this.trigger("changed");
			return;
		}
		this.store(file.path, text, true);
	}

	remove(path: string) {
		if (this.byFile.delete(path)) this.trigger("changed");
	}

	rename(file: TFile, oldPath: string) {
		const occ = this.byFile.get(oldPath);
		this.byFile.delete(oldPath);
		if (this.isExcluded(file.path) || file.extension !== "md") {
			this.trigger("changed");
		} else if (occ) {
			for (const o of occ) o.path = file.path;
			this.byFile.set(file.path, occ);
			this.trigger("changed");
		} else {
			// Moved out of an excluded folder, so it has never been scanned.
			void this.scan(file).then(() => this.trigger("changed"));
		}
	}

	private async scan(file: TFile) {
		this.store(file.path, await this.vault.cachedRead(file), false);
	}

	private store(path: string, text: string, notify: boolean) {
		const occ = extractOccurrences(path, text);
		const before = this.byFile.get(path);
		if (occ.length) this.byFile.set(path, occ);
		else this.byFile.delete(path);
		if (notify && !sameOccurrences(before, occ)) this.trigger("changed");
	}

	forFile(path: string): Occurrence[] {
		return this.byFile.get(path) ?? [];
	}

	/** book → chapter → occurrences, with books keyed by canonical index. */
	grouped(): Map<number, Map<number, Occurrence[]>> {
		const out = new Map<number, Map<number, Occurrence[]>>();
		for (const occ of this.byFile.values()) {
			for (const o of occ) {
				let chapters = out.get(o.ref.bookIndex);
				if (!chapters) out.set(o.ref.bookIndex, (chapters = new Map()));
				for (const c of chaptersOf(o.ref)) {
					const list = chapters.get(c);
					if (list) list.push(o);
					else chapters.set(c, [o]);
				}
			}
		}
		return out;
	}

	/** How many notes touch a given chapter. */
	notesOnChapter(bookIndex: number, chapter: number): number {
		let n = 0;
		for (const occ of this.byFile.values()) {
			if (occ.some((o) => o.ref.bookIndex === bookIndex && o.ref.chapter <= chapter && chapter <= o.ref.endChapter)) n++;
		}
		return n;
	}

	get noteCount() {
		return this.byFile.size;
	}
}

export function extractOccurrences(path: string, text: string): Occurrence[] {
	const masked = maskCode(text);
	const lineStarts = [0];
	for (let i = 0; i < text.length; i++) if (text[i] === "\n") lineStarts.push(i + 1);

	return findReferences(masked).map((ref) => {
		let line = 0;
		let lo = 0;
		let hi = lineStarts.length - 1;
		while (lo <= hi) {
			const mid = (lo + hi) >> 1;
			if (lineStarts[mid] <= ref.from) {
				line = mid;
				lo = mid + 1;
			} else hi = mid - 1;
		}
		const end = text.indexOf("\n", lineStarts[line]);
		const raw = text.slice(lineStarts[line], end === -1 ? text.length : end);
		return { path, line, label: formatRef(ref), snippet: snippetAround(raw, ref.from - lineStarts[line]), ref };
	});
}

function snippetAround(line: string, at: number): string {
	const clean = (s: string) => s.replace(/\s+/g, " ");
	const max = 140;
	if (line.length <= max) return clean(line.trim());
	const start = Math.max(0, at - 50);
	const cut = line.slice(start, start + max);
	return (start > 0 ? "…" : "") + clean(cut.trim()) + (start + max < line.length ? "…" : "");
}

function sameOccurrences(a: Occurrence[] | undefined, b: Occurrence[]): boolean {
	if (!a) return b.length === 0;
	if (a.length !== b.length) return false;
	return a.every((o, i) => o.label === b[i].label && o.line === b[i].line && o.snippet === b[i].snippet);
}
