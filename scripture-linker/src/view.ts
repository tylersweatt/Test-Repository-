import { debounce, ItemView, Keymap, setIcon, TFile, WorkspaceLeaf } from "obsidian";
import { BOOKS } from "./books";
import { chapterKey, Occurrence } from "./indexer";
import type ScriptureLinkerPlugin from "./main";
import { chaptersOf, findReferences } from "./parser";

export const VIEW_TYPE = "scripture-index";

export class ScriptureIndexView extends ItemView {
	private filter = "";
	private open = new Set<string>();
	private highlight: string | null = null;
	private searchEl!: HTMLInputElement;
	private currentEl!: HTMLElement;
	private libraryEl!: HTMLElement;

	constructor(leaf: WorkspaceLeaf, private plugin: ScriptureLinkerPlugin) {
		super(leaf);
	}

	getViewType() {
		return VIEW_TYPE;
	}

	getDisplayText() {
		return "Scripture Index";
	}

	getIcon() {
		return "book-open";
	}

	async onOpen() {
		const root = this.contentEl;
		root.empty();
		root.addClass("scripture-index");

		const bar = root.createDiv({ cls: "scripture-index-bar" });
		this.searchEl = bar.createEl("input", {
			type: "search",
			placeholder: "Filter: Romans 8, Psalms, or a note name",
		});
		this.searchEl.addEventListener(
			"input",
			debounce(() => {
				this.filter = this.searchEl.value.trim();
				this.renderLibrary();
			}, 200, true),
		);
		const rebuild = bar.createEl("button", { cls: "clickable-icon", attr: { "aria-label": "Rebuild index" } });
		setIcon(rebuild, "refresh-cw");
		rebuild.addEventListener("click", () => void this.plugin.index.rebuild());

		this.currentEl = root.createDiv({ cls: "scripture-index-current" });
		this.libraryEl = root.createDiv({ cls: "scripture-index-library" });

		const rerender = debounce(() => this.render(), 300, true);
		this.registerEvent(this.plugin.index.on("changed", rerender));
		this.registerEvent(this.app.workspace.on("file-open", () => this.renderCurrent()));
		this.render();
	}

	/** Jump the panel to one chapter, e.g. from a click on "Romans 8:28". */
	reveal(bookIndex: number, chapter: number) {
		const book = BOOKS[bookIndex];
		this.filter = book.chapters === 1 ? book.name : `${book.name} ${chapter}`;
		this.searchEl.value = this.filter;
		this.open.add(String(bookIndex));
		this.open.add(chapterKey(book.name, chapter));
		this.highlight = chapterKey(book.name, chapter);
		this.renderLibrary();
		this.libraryEl.querySelector(".is-highlighted")?.scrollIntoView({ block: "start" });
	}

	private render() {
		this.renderCurrent();
		this.renderLibrary();
	}

	private renderCurrent() {
		const el = this.currentEl;
		el.empty();
		const file = this.app.workspace.getActiveFile();
		if (!file || file.extension !== "md") return;
		const occ = this.plugin.index.forFile(file.path);
		if (!occ.length) return;

		el.createDiv({ cls: "scripture-index-heading", text: `In this note (${occ.length})` });
		const list = el.createDiv({ cls: "scripture-index-chips" });
		const seen = new Set<string>();
		for (const o of occ) {
			if (seen.has(o.label)) continue;
			seen.add(o.label);
			const chip = list.createEl("button", { cls: "scripture-index-chip", text: o.label });
			chip.setAttr("aria-label", "Show every note on this chapter");
			chip.addEventListener("click", () => this.reveal(o.ref.bookIndex, o.ref.chapter));
		}
	}

	private renderLibrary() {
		const el = this.libraryEl;
		el.empty();
		const index = this.plugin.index;
		if (!index.ready) {
			el.createDiv({ cls: "scripture-index-empty", text: "Indexing your vault…" });
			return;
		}

		const grouped = index.grouped();
		const q = this.filter.toLowerCase();
		const asRef = this.filter ? findReferences(this.filter)[0] : undefined;
		const refChapters = asRef ? new Set(chaptersOf(asRef)) : null;
		const filtering = q.length > 0;
		let shown = 0;

		for (const [bookIndex, chapters] of [...grouped.entries()].sort((a, b) => a[0] - b[0])) {
			const book = BOOKS[bookIndex];
			if (asRef && asRef.bookIndex !== bookIndex) continue;
			const bookMatches = !filtering || !!asRef || book.name.toLowerCase().includes(q);

			const rows: [number, Occurrence[]][] = [];
			for (const [chapter, occ] of [...chapters.entries()].sort((a, b) => a[0] - b[0])) {
				if (refChapters && !refChapters.has(chapter)) continue;
				const hits = bookMatches ? occ : occ.filter((o) => o.path.toLowerCase().includes(q));
				if (hits.length) rows.push([chapter, hits]);
			}
			if (!rows.length) continue;
			shown++;

			const bookKey = String(bookIndex);
			const noteCount = new Set(rows.flatMap(([, occ]) => occ.map((o) => o.path))).size;
			const bookEl = this.section(el, bookKey, book.name, noteCount, filtering, "scripture-index-book");

			for (const [chapter, occ] of rows) {
				const key = chapterKey(book.name, chapter);
				const label = book.chapters === 1 ? book.name : `${book.name} ${chapter}`;
				const byNote = groupByNote(occ);
				const chEl = this.section(bookEl, key, label, byNote.size, !!asRef, "scripture-index-chapter");
				if (key === this.highlight) chEl.parentElement?.addClass("is-highlighted");
				for (const [path, hits] of byNote) this.noteRow(chEl, path, hits);
			}
		}

		if (!shown) {
			el.createDiv({
				cls: "scripture-index-empty",
				text: filtering
					? "Nothing matches that filter."
					: "No Scripture references found yet. Write one like (Romans 8:28 ESV) in any note.",
			});
		} else if (!filtering) {
			el.createDiv({
				cls: "scripture-index-footnote",
				text: `${index.noteCount} ${index.noteCount === 1 ? "note" : "notes"} with Scripture references`,
			});
		}
	}

	/** A collapsible <details> block. Returns the element children go into. */
	private section(
		parent: HTMLElement,
		key: string,
		title: string,
		count: number,
		forceOpen: boolean,
		cls: string,
	): HTMLElement {
		const details = parent.createEl("details", { cls });
		details.open = forceOpen || this.open.has(key);
		const summary = details.createEl("summary");
		summary.createSpan({ text: title });
		summary.createSpan({ cls: "scripture-index-count", text: String(count) });
		details.addEventListener("toggle", () => {
			if (details.open) this.open.add(key);
			else this.open.delete(key);
		});
		return details.createDiv({ cls: "scripture-index-children" });
	}

	private noteRow(parent: HTMLElement, path: string, hits: Occurrence[]) {
		const row = parent.createDiv({ cls: "scripture-index-note" });
		const name = path.replace(/^.*\//, "").replace(/\.md$/, "");
		const title = row.createDiv({ cls: "scripture-index-note-title", text: name });
		title.addEventListener("click", (evt) => void this.openAt(path, hits[0].line, evt));

		for (const o of hits) {
			const hit = row.createDiv({ cls: "scripture-index-hit" });
			hit.createSpan({ cls: "scripture-index-hit-ref", text: o.label });
			hit.createSpan({ cls: "scripture-index-hit-snippet", text: o.snippet });
			hit.addEventListener("click", (evt) => void this.openAt(path, o.line, evt));
		}
	}

	private async openAt(path: string, line: number, evt: MouseEvent) {
		const file = this.app.vault.getAbstractFileByPath(path);
		if (!(file instanceof TFile)) return;
		const leaf = this.app.workspace.getLeaf(Keymap.isModEvent(evt));
		await leaf.openFile(file, { eState: { line }, active: true });
	}
}

function groupByNote(occ: Occurrence[]): Map<string, Occurrence[]> {
	const out = new Map<string, Occurrence[]>();
	for (const o of occ) {
		const list = out.get(o.path);
		if (!list) out.set(o.path, [o]);
		else if (!list.some((x) => x.line === o.line && x.label === o.label)) list.push(o);
	}
	return new Map([...out.entries()].sort((a, b) => a[0].localeCompare(b[0])));
}
