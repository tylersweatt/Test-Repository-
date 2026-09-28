import { BOOKS, buildAliasMap } from "./books";

export interface ScriptureRef {
	bookIndex: number;
	book: string;
	chapter: number;
	endChapter: number;
	verse?: number;
	endVerse?: number;
	/** Extra verses after a comma, e.g. ", 31, 35-37". Normalized. */
	extra: string;
	version?: string;
	/** Offsets of the match in the scanned text. */
	from: number;
	to: number;
}

const ALIASES = buildAliasMap();

const VERSIONS = ["ESV", "KJV", "NKJV", "NASB", "NIV", "CSB", "LSB", "NLT"];

const escape = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

function buildPattern(): RegExp {
	const names = [...ALIASES.keys()]
		.sort((a, b) => b.length - a.length)
		.map((a) => escape(a).replace(/ /g, "[ \\u00a0]+"))
		.join("|");
	const sp = "[ \\u00a0]";
	const dash = "[-\\u2013\\u2014]";
	// A comma item is only part of this reference if what follows it doesn't
	// look like the start of a new one ("Rom 8:28, 1 Cor 2:9").
	const listGuard = `(?![\\d:])(?!${sp}*(?:[123]|I{1,3})?${sp}?[A-Z][A-Za-z]*\\.?${sp}+\\d)`;
	const versions = VERSIONS.join("|");
	const src =
		`(?<![\\w])(${names})(?:\\.${sp}*|${sp}+)(\\d{1,3})(?!\\d)` +
		"(?:" +
		// 8:28, 8:28-30, 8:28-9:4, then ", 31, 35-37"
		`(?::(\\d{1,3})[a-c]?(?:${dash}(\\d{1,3})(?::(\\d{1,3}))?[a-c]?)?` +
		`((?:,${sp}?\\d{1,3}(?:${dash}\\d{1,3})?[a-c]?${listGuard})*))` +
		// chapter range, 8-9
		`|(?:${dash}(\\d{1,3})(?![\\d:]))` +
		")?" +
		`(?![\\w])(?:${sp}+(?:\\((${versions})\\)|(${versions})(?![\\w])))?`;
	return new RegExp(src, "g");
}

const PATTERN = buildPattern();

/** Find every Scripture reference in a piece of text. */
export function findReferences(text: string): ScriptureRef[] {
	const out: ScriptureRef[] = [];
	PATTERN.lastIndex = 0;
	let m: RegExpExecArray | null;
	while ((m = PATTERN.exec(text))) {
		const ref = toRef(m);
		if (ref) out.push(ref);
	}
	return out;
}

function toRef(m: RegExpExecArray): ScriptureRef | null {
	const alias = m[1].replace(/[  ]+/g, " ");
	const bookIndex = ALIASES.get(alias);
	if (bookIndex === undefined) return null;
	const book = BOOKS[bookIndex];

	let chapter = parseInt(m[2], 10);
	let endChapter = chapter;
	let verse: number | undefined;
	let endVerse: number | undefined;
	const extra = (m[6] ?? "")
		.split(",")
		.map((s) => s.trim().replace(/[–—]/, "-"))
		.filter(Boolean)
		.join(", ");

	if (m[3] !== undefined) {
		verse = parseInt(m[3], 10);
		if (m[5] !== undefined) {
			endChapter = parseInt(m[4], 10);
			endVerse = parseInt(m[5], 10);
		} else if (m[4] !== undefined) {
			endVerse = parseInt(m[4], 10);
		}
	} else if (m[7] !== undefined) {
		endChapter = parseInt(m[7], 10);
	} else if (book.chapters === 1) {
		// "Jude 3" means verse 3 of the only chapter.
		verse = chapter;
		chapter = endChapter = 1;
	}

	if (chapter < 1 || endChapter < chapter || endChapter > book.chapters) return null;
	if (verse === 0) return null;
	if (endVerse !== undefined && endChapter === chapter && verse !== undefined && endVerse < verse) {
		return null;
	}

	return {
		bookIndex,
		book: book.name,
		chapter,
		endChapter,
		verse,
		endVerse,
		extra,
		version: m[8] ?? m[9],
		from: m.index,
		to: m.index + m[0].length,
	};
}

/** Human label, e.g. "Romans 8:28–30" or "Jude 3". */
export function formatRef(ref: ScriptureRef, dash = "–"): string {
	const single = BOOKS[ref.bookIndex].chapters === 1;
	let s = ref.book + " ";
	if (ref.verse === undefined) {
		s += ref.chapter;
		if (ref.endChapter !== ref.chapter) s += dash + ref.endChapter;
		return s;
	}
	s += single ? `${ref.verse}` : `${ref.chapter}:${ref.verse}`;
	if (ref.endChapter !== ref.chapter) s += `${dash}${ref.endChapter}:${ref.endVerse}`;
	else if (ref.endVerse !== undefined) s += dash + ref.endVerse;
	if (ref.extra) s += ", " + ref.extra.replace(/-/g, dash);
	return s;
}

/** The query string sent to the ESV API. */
export function esvQuery(ref: ScriptureRef): string {
	return formatRef(ref, "-");
}

export function esvUrl(ref: ScriptureRef): string {
	return "https://www.esv.org/" + encodeURIComponent(esvQuery(ref)).replace(/%20/g, "+") + "/";
}

/** Every chapter a reference touches, so "Romans 8:28-9:4" counts for both. */
export function chaptersOf(ref: ScriptureRef): number[] {
	const out: number[] = [];
	for (let c = ref.chapter; c <= ref.endChapter; c++) out.push(c);
	return out;
}

/**
 * Blank out fenced code blocks and inline code so references inside them are
 * ignored. Length and line breaks are preserved, so offsets still line up.
 */
export function maskCode(text: string): string {
	const lines = text.split("\n");
	let fence: string | null = null;
	for (let i = 0; i < lines.length; i++) {
		const line = lines[i];
		const open = /^\s*(`{3,}|~{3,})/.exec(line);
		if (fence) {
			if (open && open[1][0] === fence[0] && open[1].length >= fence.length) fence = null;
			lines[i] = " ".repeat(line.length);
		} else if (open) {
			fence = open[1];
			lines[i] = " ".repeat(line.length);
		} else {
			lines[i] = line.replace(/`[^`\n]*`/g, (s) => " ".repeat(s.length));
		}
	}
	return lines.join("\n");
}
