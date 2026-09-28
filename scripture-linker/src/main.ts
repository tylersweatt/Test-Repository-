import { Editor, MarkdownPostProcessorContext, Notice, Platform, Plugin, TAbstractFile, TFile } from "obsidian";
import { scriptureEditorExtension } from "./editor";
import { EsvClient, Passage } from "./esv";
import { ScriptureIndex } from "./indexer";
import { findReferences } from "./parser";
import { refFromElement, VersePopover } from "./popover";
import { DEFAULT_SETTINGS, ScriptureLinkerSettings, ScriptureLinkerSettingTab } from "./settings";
import { ScriptureIndexView, VIEW_TYPE } from "./view";

interface PluginData {
	settings: ScriptureLinkerSettings;
	cache: Record<string, Passage>;
}

// Elements inside which reading-view text is left alone.
const SKIP_READING = "code, pre, a, .internal-link, .scripture-ref, .math, .frontmatter";

export default class ScriptureLinkerPlugin extends Plugin {
	settings!: ScriptureLinkerSettings;
	esv!: EsvClient;
	index!: ScriptureIndex;
	private cache: Record<string, Passage> = {};
	private popover!: VersePopover;

	async onload() {
		const data = ((await this.loadData()) ?? {}) as Partial<PluginData>;
		this.settings = { ...DEFAULT_SETTINGS, ...(data.settings ?? {}) };
		this.cache = data.cache ?? {};

		this.esv = new EsvClient(() => this.settings.esvApiKey, this.cache, () => void this.save());
		this.index = new ScriptureIndex(this.app.vault, (p) => this.isExcluded(p));
		this.popover = new VersePopover(this);

		this.registerView(VIEW_TYPE, (leaf) => new ScriptureIndexView(leaf, this));
		this.addRibbonIcon("book-open", "Open Scripture Index", () => void this.openView());
		this.addSettingTab(new ScriptureLinkerSettingTab(this.app, this));

		if (this.settings.decorateEditor) this.registerEditorExtension(scriptureEditorExtension);
		this.registerMarkdownPostProcessor((el, ctx) => this.linkReadingView(el, ctx));

		this.registerCommands();
		this.registerHover();
		this.registerIndexEvents();

		this.app.workspace.onLayoutReady(() => void this.index.rebuild());
	}

	onunload() {
		this.popover.hide();
	}

	async save() {
		await this.saveData({ settings: this.settings, cache: this.cache } satisfies PluginData);
	}

	isExcluded(path: string): boolean {
		return this.settings.excludedFolders
			.split(/[\n,]/)
			.map((f) => f.trim().replace(/^\/+|\/+$/g, ""))
			.filter(Boolean)
			.some((f) => path === f || path.startsWith(f + "/"));
	}

	notesOnChapter(bookIndex: number, chapter: number): number {
		return this.index.notesOnChapter(bookIndex, chapter);
	}

	async openView(): Promise<ScriptureIndexView | null> {
		const { workspace } = this.app;
		let leaf = workspace.getLeavesOfType(VIEW_TYPE)[0];
		if (!leaf) {
			leaf = workspace.getRightLeaf(false) ?? workspace.getLeaf(true);
			await leaf.setViewState({ type: VIEW_TYPE, active: true });
		}
		await workspace.revealLeaf(leaf);
		return leaf.view instanceof ScriptureIndexView ? leaf.view : null;
	}

	async revealChapter(bookIndex: number, chapter: number) {
		const view = await this.openView();
		view?.reveal(bookIndex, chapter);
	}

	private registerCommands() {
		this.addCommand({
			id: "open-index",
			name: "Open Scripture Index",
			callback: () => void this.openView(),
		});
		this.addCommand({
			id: "show-chapter-at-cursor",
			name: "Show every note on the chapter under the cursor",
			editorCallback: (editor: Editor) => {
				const cur = editor.getCursor();
				const line = editor.getLine(cur.line);
				const refs = findReferences(line);
				const ref = refs.find((r) => r.from <= cur.ch && cur.ch <= r.to) ?? refs[0];
				if (!ref) {
					new Notice("No Scripture reference on this line.");
					return;
				}
				void this.revealChapter(ref.bookIndex, ref.chapter);
			},
		});
		this.addCommand({
			id: "rebuild-index",
			name: "Rebuild Scripture Index",
			callback: async () => {
				await this.index.rebuild();
				new Notice(`Scripture Index rebuilt: ${this.index.noteCount} notes with references.`);
			},
		});
	}

	/** Wrap references in reading view (and hover previews) in a styled span. */
	private linkReadingView(el: HTMLElement, _ctx: MarkdownPostProcessorContext) {
		if (!this.settings.decorateReading) return;
		const walker = el.ownerDocument.createTreeWalker(el, NodeFilter.SHOW_TEXT, {
			acceptNode: (node) =>
				node.parentElement?.closest(SKIP_READING) ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT,
		});
		const nodes: Text[] = [];
		for (let n = walker.nextNode(); n; n = walker.nextNode()) nodes.push(n as Text);

		for (const node of nodes) {
			const text = node.data;
			const refs = findReferences(text);
			if (!refs.length) continue;
			const frag = el.ownerDocument.createDocumentFragment();
			let last = 0;
			for (const ref of refs) {
				frag.append(text.slice(last, ref.from));
				const raw = text.slice(ref.from, ref.to);
				frag.append(
					createSpan({ cls: "scripture-ref", text: raw, attr: { "data-scripture-ref": raw } }),
				);
				last = ref.to;
			}
			frag.append(text.slice(last));
			node.replaceWith(frag);
		}
	}

	private registerHover() {
		const refAt = (target: EventTarget | null): HTMLElement | null =>
			target instanceof HTMLElement ? target.closest<HTMLElement>(".scripture-ref") : null;

		if (!Platform.isMobile) {
			this.registerDomEvent(document, "mouseover", (evt) => {
				if (!this.settings.showHover) return;
				const el = refAt(evt.target);
				if (el) this.popover.scheduleShow(el);
			});
			this.registerDomEvent(document, "mouseout", (evt) => {
				const from = refAt(evt.target);
				if (!from) return;
				const to = evt.relatedTarget as Node | null;
				if (this.popover.contains(to) || from.contains(to)) return;
				this.popover.scheduleHide();
			});
		}

		this.registerDomEvent(document, "click", (evt) => {
			const target = evt.target as Node | null;
			if (this.popover.contains(target)) return;
			const el = refAt(evt.target);
			if (!el) {
				this.popover.hide();
				return;
			}
			const inEditor = !!el.closest(".cm-editor");
			const ref = refFromElement(el);
			if (!ref) return;

			if (Platform.isMobile) {
				// No hover on a phone, so a tap in reading view shows the verse card.
				if (inEditor) return;
				evt.preventDefault();
				this.popover.show(el);
				return;
			}
			// In the editor a plain click just places the cursor.
			if (inEditor && !(evt.metaKey || evt.ctrlKey)) return;
			evt.preventDefault();
			this.popover.hide();
			void this.revealChapter(ref.bookIndex, ref.chapter);
		});
	}

	private registerIndexEvents() {
		this.registerEvent(
			this.app.metadataCache.on("changed", (file, data) => this.index.update(file, data)),
		);
		this.registerEvent(
			this.app.vault.on("delete", (file: TAbstractFile) => this.index.remove(file.path)),
		);
		this.registerEvent(
			this.app.vault.on("rename", (file: TAbstractFile, oldPath: string) => {
				if (file instanceof TFile) this.index.rename(file, oldPath);
			}),
		);
	}
}
