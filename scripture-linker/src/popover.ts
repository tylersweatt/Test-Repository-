import { BOOKS } from "./books";
import type ScriptureLinkerPlugin from "./main";
import { esvQuery, esvUrl, findReferences, formatRef, ScriptureRef } from "./parser";

/** The verse card shown when hovering (or tapping) a reference. */
export class VersePopover {
	private el: HTMLElement | null = null;
	private anchor: HTMLElement | null = null;
	private showTimer: number | null = null;
	private hideTimer: number | null = null;

	constructor(private plugin: ScriptureLinkerPlugin) {}

	/** Show after the hover delay, unless the pointer leaves first. */
	scheduleShow(anchor: HTMLElement) {
		this.cancelHide();
		if (anchor === this.anchor) return;
		this.cancelShow();
		this.showTimer = window.setTimeout(() => this.show(anchor), this.plugin.settings.hoverDelay);
	}

	scheduleHide() {
		this.cancelShow();
		this.cancelHide();
		this.hideTimer = window.setTimeout(() => this.hide(), 250);
	}

	cancelShow() {
		if (this.showTimer !== null) window.clearTimeout(this.showTimer);
		this.showTimer = null;
	}

	cancelHide() {
		if (this.hideTimer !== null) window.clearTimeout(this.hideTimer);
		this.hideTimer = null;
	}

	contains(node: Node | null): boolean {
		return !!node && !!this.el && this.el.contains(node);
	}

	isAnchor(node: Node | null): boolean {
		return !!node && !!this.anchor && this.anchor.contains(node);
	}

	show(anchor: HTMLElement) {
		const ref = refFromElement(anchor);
		if (!ref) return;
		this.hide();
		this.anchor = anchor;

		const doc = anchor.ownerDocument;
		const el = doc.body.createDiv({ cls: "scripture-popover" });
		this.el = el;
		el.addEventListener("mouseenter", () => this.cancelHide());
		el.addEventListener("mouseleave", () => this.scheduleHide());

		const header = el.createDiv({ cls: "scripture-popover-header" });
		header.createSpan({ cls: "scripture-popover-title", text: formatRef(ref) });
		header.createSpan({ cls: "scripture-popover-version", text: "ESV" });

		const body = el.createDiv({ cls: "scripture-popover-body" });
		const footer = el.createDiv({ cls: "scripture-popover-footer" });

		const count = this.plugin.notesOnChapter(ref.bookIndex, ref.chapter);
		const chapterLabel = BOOKS[ref.bookIndex].chapters === 1 ? ref.book : `${ref.book} ${ref.chapter}`;
		const indexBtn = footer.createEl("button", {
			text: `${count} ${count === 1 ? "note" : "notes"} on ${chapterLabel}`,
		});
		indexBtn.addEventListener("click", () => {
			this.hide();
			void this.plugin.revealChapter(ref.bookIndex, ref.chapter);
		});
		footer.createEl("a", { text: "esv.org", href: esvUrl(ref), cls: "scripture-popover-link" });

		this.fillBody(body, ref);
		this.position(anchor);
	}

	private fillBody(body: HTMLElement, ref: ScriptureRef) {
		const esv = this.plugin.esv;
		if (!esv.hasKey) {
			body.addClass("is-muted");
			body.setText("Add a free ESV API key in Scripture Linker settings to see the verse text here.");
			return;
		}
		body.addClass("is-loading");
		body.setText("Loading…");
		const el = this.el;
		esv.fetch(esvQuery(ref)).then(
			(passage) => {
				if (this.el !== el) return;
				body.removeClass("is-loading");
				body.setText(passage.text);
				this.position(this.anchor);
			},
			(err: Error) => {
				if (this.el !== el) return;
				body.removeClass("is-loading");
				body.addClass("is-error");
				body.setText(err.message);
			},
		);
	}

	private position(anchor: HTMLElement | null) {
		const el = this.el;
		if (!el || !anchor) return;
		const win = anchor.ownerDocument.defaultView ?? window;
		const r = anchor.getBoundingClientRect();
		const margin = 8;
		const w = el.offsetWidth;
		const h = el.offsetHeight;
		let left = Math.min(r.left, win.innerWidth - w - margin);
		left = Math.max(margin, left);
		let top = r.bottom + 6;
		if (top + h > win.innerHeight - margin && r.top - h - 6 > margin) top = r.top - h - 6;
		el.style.left = `${left}px`;
		el.style.top = `${top}px`;
	}

	hide() {
		this.cancelShow();
		this.cancelHide();
		this.el?.remove();
		this.el = null;
		this.anchor = null;
	}
}

export function refFromElement(el: HTMLElement): ScriptureRef | null {
	const raw = el.dataset.scriptureRef ?? el.textContent ?? "";
	return findReferences(raw)[0] ?? null;
}
