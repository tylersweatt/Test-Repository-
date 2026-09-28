"use strict";
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/main.ts
var main_exports = {};
__export(main_exports, {
  default: () => ScriptureLinkerPlugin
});
module.exports = __toCommonJS(main_exports);
var import_obsidian5 = require("obsidian");

// src/editor.ts
var import_language = require("@codemirror/language");
var import_state = require("@codemirror/state");
var import_view = require("@codemirror/view");

// src/books.ts
var OT = [
  { name: "Genesis", chapters: 50, aliases: ["Gen", "Gn"] },
  { name: "Exodus", chapters: 40, aliases: ["Exod", "Exo", "Ex"] },
  { name: "Leviticus", chapters: 27, aliases: ["Lev", "Lv"] },
  { name: "Numbers", chapters: 36, aliases: ["Num", "Nm", "Nu"] },
  { name: "Deuteronomy", chapters: 34, aliases: ["Deut", "Dt", "Deu"] },
  { name: "Joshua", chapters: 24, aliases: ["Josh", "Jos"] },
  { name: "Judges", chapters: 21, aliases: ["Judg", "Jdg", "Jgs"] },
  { name: "Ruth", chapters: 4, aliases: ["Rth"] },
  { name: "1 Samuel", chapters: 31, aliases: ["Samuel", "Sam", "Sm"] },
  { name: "2 Samuel", chapters: 24, aliases: ["Samuel", "Sam", "Sm"] },
  { name: "1 Kings", chapters: 22, aliases: ["Kings", "Kgs", "Ki"] },
  { name: "2 Kings", chapters: 25, aliases: ["Kings", "Kgs", "Ki"] },
  { name: "1 Chronicles", chapters: 29, aliases: ["Chronicles", "Chron", "Chr", "Ch"] },
  { name: "2 Chronicles", chapters: 36, aliases: ["Chronicles", "Chron", "Chr", "Ch"] },
  { name: "Ezra", chapters: 10, aliases: ["Ezr"] },
  { name: "Nehemiah", chapters: 13, aliases: ["Neh", "Ne"] },
  { name: "Esther", chapters: 10, aliases: ["Esth", "Est"] },
  { name: "Job", chapters: 42, aliases: ["Jb"] },
  { name: "Psalms", chapters: 150, aliases: ["Psalm", "Pss", "Psa", "Ps"] },
  { name: "Proverbs", chapters: 31, aliases: ["Prov", "Pro", "Prv", "Pr"] },
  { name: "Ecclesiastes", chapters: 12, aliases: ["Eccles", "Eccl", "Ecc", "Qoh"] },
  { name: "Song of Solomon", chapters: 8, aliases: ["Song of Songs", "Sng"] },
  { name: "Isaiah", chapters: 66, aliases: ["Isa"] },
  { name: "Jeremiah", chapters: 52, aliases: ["Jer"] },
  { name: "Lamentations", chapters: 5, aliases: ["Lam"] },
  { name: "Ezekiel", chapters: 48, aliases: ["Ezek", "Eze", "Ezk"] },
  { name: "Daniel", chapters: 12, aliases: ["Dan", "Dn"] },
  { name: "Hosea", chapters: 14, aliases: ["Hos"] },
  { name: "Joel", chapters: 3, aliases: ["Jl"] },
  { name: "Amos", chapters: 9, aliases: [] },
  { name: "Obadiah", chapters: 1, aliases: ["Obad", "Ob"] },
  { name: "Jonah", chapters: 4, aliases: [] },
  { name: "Micah", chapters: 7, aliases: ["Mic"] },
  { name: "Nahum", chapters: 3, aliases: ["Nah"] },
  { name: "Habakkuk", chapters: 3, aliases: ["Hab", "Hb"] },
  { name: "Zephaniah", chapters: 3, aliases: ["Zeph", "Zep"] },
  { name: "Haggai", chapters: 2, aliases: ["Hag", "Hg"] },
  { name: "Zechariah", chapters: 14, aliases: ["Zech", "Zec"] },
  { name: "Malachi", chapters: 4, aliases: ["Mal"] }
];
var NT = [
  { name: "Matthew", chapters: 28, aliases: ["Matt", "Mat", "Mt"] },
  { name: "Mark", chapters: 16, aliases: ["Mrk", "Mk"] },
  { name: "Luke", chapters: 24, aliases: ["Luk", "Lk"] },
  { name: "John", chapters: 21, aliases: ["Jhn", "Jn"] },
  { name: "Acts", chapters: 28, aliases: [] },
  { name: "Romans", chapters: 16, aliases: ["Rom", "Rm"] },
  { name: "1 Corinthians", chapters: 16, aliases: ["Corinthians", "Cor"] },
  { name: "2 Corinthians", chapters: 13, aliases: ["Corinthians", "Cor"] },
  { name: "Galatians", chapters: 6, aliases: ["Gal", "Ga"] },
  { name: "Ephesians", chapters: 6, aliases: ["Eph", "Ephes"] },
  { name: "Philippians", chapters: 4, aliases: ["Phil", "Php", "Pp"] },
  { name: "Colossians", chapters: 4, aliases: ["Col"] },
  { name: "1 Thessalonians", chapters: 5, aliases: ["Thessalonians", "Thess", "Thes"] },
  { name: "2 Thessalonians", chapters: 3, aliases: ["Thessalonians", "Thess", "Thes"] },
  { name: "1 Timothy", chapters: 6, aliases: ["Timothy", "Tim"] },
  { name: "2 Timothy", chapters: 4, aliases: ["Timothy", "Tim"] },
  { name: "Titus", chapters: 3, aliases: ["Tit"] },
  { name: "Philemon", chapters: 1, aliases: ["Philem", "Phm", "Pm"] },
  { name: "Hebrews", chapters: 13, aliases: ["Heb"] },
  { name: "James", chapters: 5, aliases: ["Jas", "Jm"] },
  { name: "1 Peter", chapters: 5, aliases: ["Peter", "Pet", "Pt"] },
  { name: "2 Peter", chapters: 3, aliases: ["Peter", "Pet", "Pt"] },
  { name: "1 John", chapters: 5, aliases: ["John", "Jhn", "Jn"] },
  { name: "2 John", chapters: 1, aliases: ["John", "Jhn", "Jn"] },
  { name: "3 John", chapters: 1, aliases: ["John", "Jhn", "Jn"] },
  { name: "Jude", chapters: 1, aliases: ["Jud", "Jd"] },
  { name: "Revelation", chapters: 22, aliases: ["Rev", "Rv", "Revelations"] }
];
var BOOKS = [...OT, ...NT];
var PREFIXES = {
  "1": ["1", "1st", "First", "I"],
  "2": ["2", "2nd", "Second", "II"],
  "3": ["3", "3rd", "Third", "III"]
};
function buildAliasMap() {
  const map = /* @__PURE__ */ new Map();
  BOOKS.forEach((book, i) => {
    const m = /^([123]) (.+)$/.exec(book.name);
    if (m) {
      const stems = [m[2], ...book.aliases];
      for (const prefix of PREFIXES[m[1]]) {
        for (const stem of stems) {
          map.set(`${prefix} ${stem}`, i);
          if (/^\d/.test(prefix)) map.set(`${prefix}${stem}`, i);
        }
      }
    } else {
      map.set(book.name, i);
      for (const alias of book.aliases) map.set(alias, i);
    }
  });
  return map;
}

// src/parser.ts
var ALIASES = buildAliasMap();
var VERSIONS = ["ESV", "KJV", "NKJV", "NASB", "NIV", "CSB", "LSB", "NLT"];
var escape = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
function buildPattern() {
  const names = [...ALIASES.keys()].sort((a, b) => b.length - a.length).map((a) => escape(a).replace(/ /g, "[ \\u00a0]+")).join("|");
  const sp = "[ \\u00a0]";
  const dash = "[-\\u2013\\u2014]";
  const listGuard = `(?![\\d:])(?!${sp}*(?:[123]|I{1,3})?${sp}?[A-Z][A-Za-z]*\\.?${sp}+\\d)`;
  const versions = VERSIONS.join("|");
  const src = `(?<![\\w])(${names})(?:\\.${sp}*|${sp}+)(\\d{1,3})(?!\\d)(?:(?::(\\d{1,3})[a-c]?(?:${dash}(\\d{1,3})(?::(\\d{1,3}))?[a-c]?)?((?:,${sp}?\\d{1,3}(?:${dash}\\d{1,3})?[a-c]?${listGuard})*))|(?:${dash}(\\d{1,3})(?![\\d:])))?(?![\\w])(?:${sp}+(?:\\((${versions})\\)|(${versions})(?![\\w])))?`;
  return new RegExp(src, "g");
}
var PATTERN = buildPattern();
function findReferences(text) {
  const out = [];
  PATTERN.lastIndex = 0;
  let m;
  while (m = PATTERN.exec(text)) {
    const ref = toRef(m);
    if (ref) out.push(ref);
  }
  return out;
}
function toRef(m) {
  const alias = m[1].replace(/[  ]+/g, " ");
  const bookIndex = ALIASES.get(alias);
  if (bookIndex === void 0) return null;
  const book = BOOKS[bookIndex];
  let chapter = parseInt(m[2], 10);
  let endChapter = chapter;
  let verse;
  let endVerse;
  const extra = (m[6] ?? "").split(",").map((s) => s.trim().replace(/[–—]/, "-")).filter(Boolean).join(", ");
  if (m[3] !== void 0) {
    verse = parseInt(m[3], 10);
    if (m[5] !== void 0) {
      endChapter = parseInt(m[4], 10);
      endVerse = parseInt(m[5], 10);
    } else if (m[4] !== void 0) {
      endVerse = parseInt(m[4], 10);
    }
  } else if (m[7] !== void 0) {
    endChapter = parseInt(m[7], 10);
  } else if (book.chapters === 1) {
    verse = chapter;
    chapter = endChapter = 1;
  }
  if (chapter < 1 || endChapter < chapter || endChapter > book.chapters) return null;
  if (verse === 0) return null;
  if (endVerse !== void 0 && endChapter === chapter && verse !== void 0 && endVerse < verse) {
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
    to: m.index + m[0].length
  };
}
function formatRef(ref, dash = "\u2013") {
  const single = BOOKS[ref.bookIndex].chapters === 1;
  let s = ref.book + " ";
  if (ref.verse === void 0) {
    s += ref.chapter;
    if (ref.endChapter !== ref.chapter) s += dash + ref.endChapter;
    return s;
  }
  s += single ? `${ref.verse}` : `${ref.chapter}:${ref.verse}`;
  if (ref.endChapter !== ref.chapter) s += `${dash}${ref.endChapter}:${ref.endVerse}`;
  else if (ref.endVerse !== void 0) s += dash + ref.endVerse;
  if (ref.extra) s += ", " + ref.extra.replace(/-/g, dash);
  return s;
}
function esvQuery(ref) {
  return formatRef(ref, "-");
}
function esvUrl(ref) {
  return "https://www.esv.org/" + encodeURIComponent(esvQuery(ref)).replace(/%20/g, "+") + "/";
}
function chaptersOf(ref) {
  const out = [];
  for (let c = ref.chapter; c <= ref.endChapter; c++) out.push(c);
  return out;
}
function maskCode(text) {
  const lines = text.split("\n");
  let fence = null;
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

// src/editor.ts
var SKIP_NODE = /code|link|url|math|comment|hashtag|frontmatter/i;
function build(view) {
  const builder = new import_state.RangeSetBuilder();
  const tree = (0, import_language.syntaxTree)(view.state);
  const doc = view.state.doc;
  for (const { from, to } of view.visibleRanges) {
    const start = doc.lineAt(from).from;
    const end = doc.lineAt(to).to;
    const text = doc.sliceString(start, end);
    for (const ref of findReferences(text)) {
      const a = start + ref.from;
      const b = start + ref.to;
      let skip = false;
      for (let node = tree.resolveInner(a, 1); node; node = node.parent) {
        if (SKIP_NODE.test(node.name)) {
          skip = true;
          break;
        }
      }
      if (skip) continue;
      builder.add(
        a,
        b,
        import_view.Decoration.mark({
          class: "scripture-ref",
          attributes: { "data-scripture-ref": text.slice(ref.from, ref.to) }
        })
      );
    }
  }
  return builder.finish();
}
var scriptureEditorExtension = import_view.ViewPlugin.fromClass(
  class {
    constructor(view) {
      this.decorations = build(view);
    }
    update(u) {
      if (u.docChanged || u.viewportChanged || (0, import_language.syntaxTree)(u.startState) !== (0, import_language.syntaxTree)(u.state)) {
        this.decorations = build(u.view);
      }
    }
  },
  { decorations: (v) => v.decorations }
);

// src/esv.ts
var import_obsidian = require("obsidian");
var MAX_CACHED = 100;
var EsvClient = class {
  constructor(getKey, cache, persist) {
    this.getKey = getKey;
    this.cache = cache;
    this.persist = persist;
    this.inflight = /* @__PURE__ */ new Map();
  }
  get hasKey() {
    return this.getKey().trim().length > 0;
  }
  async fetch(query) {
    const hit = this.cache[query];
    if (hit) return hit;
    const pending = this.inflight.get(query);
    if (pending) return pending;
    const p = this.request(query).finally(() => this.inflight.delete(query));
    this.inflight.set(query, p);
    return p;
  }
  async request(query) {
    const params = new URLSearchParams({
      q: query,
      "include-passage-references": "false",
      "include-verse-numbers": "true",
      "include-first-verse-numbers": "false",
      "include-footnotes": "false",
      "include-headings": "false",
      "include-short-copyright": "false",
      "include-selahs": "true",
      "indent-poetry": "true"
    });
    const res = await (0, import_obsidian.requestUrl)({
      url: `https://api.esv.org/v3/passage/text/?${params}`,
      headers: { Authorization: `Token ${this.getKey().trim()}` },
      throw: false
    });
    if (res.status === 401 || res.status === 403) {
      throw new Error("The ESV API key was rejected. Check it in the Scripture Linker settings.");
    }
    if (res.status !== 200) throw new Error(`ESV API returned ${res.status}.`);
    const body = res.json;
    const text = (body.passages ?? []).join("\n\n").trim();
    if (!text) throw new Error("No passage found.");
    const passage = { reference: body.canonical ?? query, text, fetchedAt: Date.now() };
    this.cache[query] = passage;
    this.trim();
    this.persist();
    return passage;
  }
  trim() {
    const keys = Object.keys(this.cache);
    if (keys.length <= MAX_CACHED) return;
    keys.sort((a, b) => this.cache[a].fetchedAt - this.cache[b].fetchedAt);
    for (const k of keys.slice(0, keys.length - MAX_CACHED)) delete this.cache[k];
  }
  clear() {
    for (const k of Object.keys(this.cache)) delete this.cache[k];
    this.persist();
  }
};

// src/indexer.ts
var import_obsidian2 = require("obsidian");
var chapterKey = (book, chapter) => `${book}|${chapter}`;
var ScriptureIndex = class extends import_obsidian2.Events {
  constructor(vault, isExcluded) {
    super();
    this.vault = vault;
    this.isExcluded = isExcluded;
    this.byFile = /* @__PURE__ */ new Map();
    this.ready = false;
  }
  async rebuild() {
    this.byFile.clear();
    const files = this.vault.getMarkdownFiles().filter((f) => !this.isExcluded(f.path));
    for (let i = 0; i < files.length; i += 50) {
      await Promise.all(files.slice(i, i + 50).map((f) => this.scan(f)));
    }
    this.ready = true;
    this.trigger("changed");
  }
  /** Called with the note's fresh contents whenever Obsidian re-parses it. */
  update(file, text) {
    if (file.extension !== "md") return;
    if (this.isExcluded(file.path)) {
      if (this.byFile.delete(file.path)) this.trigger("changed");
      return;
    }
    this.store(file.path, text, true);
  }
  remove(path) {
    if (this.byFile.delete(path)) this.trigger("changed");
  }
  rename(file, oldPath) {
    const occ = this.byFile.get(oldPath);
    this.byFile.delete(oldPath);
    if (this.isExcluded(file.path) || file.extension !== "md") {
      this.trigger("changed");
    } else if (occ) {
      for (const o of occ) o.path = file.path;
      this.byFile.set(file.path, occ);
      this.trigger("changed");
    } else {
      void this.scan(file).then(() => this.trigger("changed"));
    }
  }
  async scan(file) {
    this.store(file.path, await this.vault.cachedRead(file), false);
  }
  store(path, text, notify) {
    const occ = extractOccurrences(path, text);
    const before = this.byFile.get(path);
    if (occ.length) this.byFile.set(path, occ);
    else this.byFile.delete(path);
    if (notify && !sameOccurrences(before, occ)) this.trigger("changed");
  }
  forFile(path) {
    return this.byFile.get(path) ?? [];
  }
  /** book → chapter → occurrences, with books keyed by canonical index. */
  grouped() {
    const out = /* @__PURE__ */ new Map();
    for (const occ of this.byFile.values()) {
      for (const o of occ) {
        let chapters = out.get(o.ref.bookIndex);
        if (!chapters) out.set(o.ref.bookIndex, chapters = /* @__PURE__ */ new Map());
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
  notesOnChapter(bookIndex, chapter) {
    let n = 0;
    for (const occ of this.byFile.values()) {
      if (occ.some((o) => o.ref.bookIndex === bookIndex && o.ref.chapter <= chapter && chapter <= o.ref.endChapter)) n++;
    }
    return n;
  }
  get noteCount() {
    return this.byFile.size;
  }
};
function extractOccurrences(path, text) {
  const masked = maskCode(text);
  const lineStarts = [0];
  for (let i = 0; i < text.length; i++) if (text[i] === "\n") lineStarts.push(i + 1);
  return findReferences(masked).map((ref) => {
    let line = 0;
    let lo = 0;
    let hi = lineStarts.length - 1;
    while (lo <= hi) {
      const mid = lo + hi >> 1;
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
function snippetAround(line, at) {
  const clean = (s) => s.replace(/\s+/g, " ");
  const max = 140;
  if (line.length <= max) return clean(line.trim());
  const start = Math.max(0, at - 50);
  const cut = line.slice(start, start + max);
  return (start > 0 ? "\u2026" : "") + clean(cut.trim()) + (start + max < line.length ? "\u2026" : "");
}
function sameOccurrences(a, b) {
  if (!a) return b.length === 0;
  if (a.length !== b.length) return false;
  return a.every((o, i) => o.label === b[i].label && o.line === b[i].line && o.snippet === b[i].snippet);
}

// src/popover.ts
var VersePopover = class {
  constructor(plugin) {
    this.plugin = plugin;
    this.el = null;
    this.anchor = null;
    this.showTimer = null;
    this.hideTimer = null;
  }
  /** Show after the hover delay, unless the pointer leaves first. */
  scheduleShow(anchor) {
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
  contains(node) {
    return !!node && !!this.el && this.el.contains(node);
  }
  isAnchor(node) {
    return !!node && !!this.anchor && this.anchor.contains(node);
  }
  show(anchor) {
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
      text: `${count} ${count === 1 ? "note" : "notes"} on ${chapterLabel}`
    });
    indexBtn.addEventListener("click", () => {
      this.hide();
      void this.plugin.revealChapter(ref.bookIndex, ref.chapter);
    });
    footer.createEl("a", { text: "esv.org", href: esvUrl(ref), cls: "scripture-popover-link" });
    this.fillBody(body, ref);
    this.position(anchor);
  }
  fillBody(body, ref) {
    const esv = this.plugin.esv;
    if (!esv.hasKey) {
      body.addClass("is-muted");
      body.setText("Add a free ESV API key in Scripture Linker settings to see the verse text here.");
      return;
    }
    body.addClass("is-loading");
    body.setText("Loading\u2026");
    const el = this.el;
    esv.fetch(esvQuery(ref)).then(
      (passage) => {
        if (this.el !== el) return;
        body.removeClass("is-loading");
        body.setText(passage.text);
        this.position(this.anchor);
      },
      (err) => {
        if (this.el !== el) return;
        body.removeClass("is-loading");
        body.addClass("is-error");
        body.setText(err.message);
      }
    );
  }
  position(anchor) {
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
};
function refFromElement(el) {
  const raw = el.dataset.scriptureRef ?? el.textContent ?? "";
  return findReferences(raw)[0] ?? null;
}

// src/settings.ts
var import_obsidian3 = require("obsidian");
var DEFAULT_SETTINGS = {
  esvApiKey: "",
  showHover: true,
  hoverDelay: 300,
  decorateEditor: true,
  decorateReading: true,
  excludedFolders: ""
};
var ScriptureLinkerSettingTab = class extends import_obsidian3.PluginSettingTab {
  constructor(app, plugin) {
    super(app, plugin);
    this.plugin = plugin;
  }
  display() {
    const { containerEl } = this;
    containerEl.empty();
    const s = this.plugin.settings;
    const save = () => void this.plugin.save();
    new import_obsidian3.Setting(containerEl).setName("ESV text").setHeading();
    const keyDesc = createFragment((f) => {
      f.appendText("Needed to show verse text on hover. Get a free key at ");
      f.createEl("a", { text: "api.esv.org", href: "https://api.esv.org/account/create-application/" });
      f.appendText(". Without one, references are still linked and indexed.");
    });
    new import_obsidian3.Setting(containerEl).setName("ESV API key").setDesc(keyDesc).addText((t) => {
      t.inputEl.type = "password";
      t.setPlaceholder("Paste your key").setValue(s.esvApiKey).onChange((v) => {
        s.esvApiKey = v.trim();
        save();
      });
    });
    new import_obsidian3.Setting(containerEl).setName("Clear saved verses").setDesc("Passages are cached so hovering is instant. The cache keeps the last 100.").addButton(
      (b) => b.setButtonText("Clear").onClick(() => {
        this.plugin.esv.clear();
        new import_obsidian3.Notice("Saved verses cleared.");
      })
    );
    new import_obsidian3.Setting(containerEl).setName("Links").setHeading();
    new import_obsidian3.Setting(containerEl).setName("Show verse on hover").addToggle((t) => t.setValue(s.showHover).onChange((v) => {
      s.showHover = v;
      save();
    }));
    new import_obsidian3.Setting(containerEl).setName("Hover delay").setDesc("Milliseconds before the verse card appears.").addSlider(
      (sl) => sl.setLimits(0, 1e3, 50).setValue(s.hoverDelay).setDynamicTooltip().onChange((v) => {
        s.hoverDelay = v;
        save();
      })
    );
    new import_obsidian3.Setting(containerEl).setName("Link references in the editor").setDesc("Ctrl/Cmd-click a reference to see every note on that chapter. Takes effect after reloading Obsidian.").addToggle((t) => t.setValue(s.decorateEditor).onChange((v) => {
      s.decorateEditor = v;
      save();
    }));
    new import_obsidian3.Setting(containerEl).setName("Link references in reading view").addToggle((t) => t.setValue(s.decorateReading).onChange((v) => {
      s.decorateReading = v;
      save();
    }));
    new import_obsidian3.Setting(containerEl).setName("Index").setHeading();
    new import_obsidian3.Setting(containerEl).setName("Excluded folders").setDesc("One per line. Notes here are left out of the Scripture Index, e.g. Templates.").addTextArea(
      (t) => t.setValue(s.excludedFolders).onChange((v) => {
        s.excludedFolders = v;
        save();
      })
    ).addButton(
      (b) => b.setButtonText("Rebuild index").onClick(async () => {
        await this.plugin.index.rebuild();
        new import_obsidian3.Notice(`Scripture Index rebuilt: ${this.plugin.index.noteCount} notes with references.`);
      })
    );
  }
};

// src/view.ts
var import_obsidian4 = require("obsidian");
var VIEW_TYPE = "scripture-index";
var ScriptureIndexView = class extends import_obsidian4.ItemView {
  constructor(leaf, plugin) {
    super(leaf);
    this.plugin = plugin;
    this.filter = "";
    this.open = /* @__PURE__ */ new Set();
    this.highlight = null;
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
      placeholder: "Filter: Romans 8, Psalms, or a note name"
    });
    this.searchEl.addEventListener(
      "input",
      (0, import_obsidian4.debounce)(() => {
        this.filter = this.searchEl.value.trim();
        this.renderLibrary();
      }, 200, true)
    );
    const rebuild = bar.createEl("button", { cls: "clickable-icon", attr: { "aria-label": "Rebuild index" } });
    (0, import_obsidian4.setIcon)(rebuild, "refresh-cw");
    rebuild.addEventListener("click", () => void this.plugin.index.rebuild());
    this.currentEl = root.createDiv({ cls: "scripture-index-current" });
    this.libraryEl = root.createDiv({ cls: "scripture-index-library" });
    const rerender = (0, import_obsidian4.debounce)(() => this.render(), 300, true);
    this.registerEvent(this.plugin.index.on("changed", rerender));
    this.registerEvent(this.app.workspace.on("file-open", () => this.renderCurrent()));
    this.render();
  }
  /** Jump the panel to one chapter, e.g. from a click on "Romans 8:28". */
  reveal(bookIndex, chapter) {
    const book = BOOKS[bookIndex];
    this.filter = book.chapters === 1 ? book.name : `${book.name} ${chapter}`;
    this.searchEl.value = this.filter;
    this.open.add(String(bookIndex));
    this.open.add(chapterKey(book.name, chapter));
    this.highlight = chapterKey(book.name, chapter);
    this.renderLibrary();
    this.libraryEl.querySelector(".is-highlighted")?.scrollIntoView({ block: "start" });
  }
  render() {
    this.renderCurrent();
    this.renderLibrary();
  }
  renderCurrent() {
    const el = this.currentEl;
    el.empty();
    const file = this.app.workspace.getActiveFile();
    if (!file || file.extension !== "md") return;
    const occ = this.plugin.index.forFile(file.path);
    if (!occ.length) return;
    el.createDiv({ cls: "scripture-index-heading", text: `In this note (${occ.length})` });
    const list = el.createDiv({ cls: "scripture-index-chips" });
    const seen = /* @__PURE__ */ new Set();
    for (const o of occ) {
      if (seen.has(o.label)) continue;
      seen.add(o.label);
      const chip = list.createEl("button", { cls: "scripture-index-chip", text: o.label });
      chip.setAttr("aria-label", "Show every note on this chapter");
      chip.addEventListener("click", () => this.reveal(o.ref.bookIndex, o.ref.chapter));
    }
  }
  renderLibrary() {
    const el = this.libraryEl;
    el.empty();
    const index = this.plugin.index;
    if (!index.ready) {
      el.createDiv({ cls: "scripture-index-empty", text: "Indexing your vault\u2026" });
      return;
    }
    const grouped = index.grouped();
    const q = this.filter.toLowerCase();
    const asRef = this.filter ? findReferences(this.filter)[0] : void 0;
    const refChapters = asRef ? new Set(chaptersOf(asRef)) : null;
    const filtering = q.length > 0;
    let shown = 0;
    for (const [bookIndex, chapters] of [...grouped.entries()].sort((a, b) => a[0] - b[0])) {
      const book = BOOKS[bookIndex];
      if (asRef && asRef.bookIndex !== bookIndex) continue;
      const bookMatches = !filtering || !!asRef || book.name.toLowerCase().includes(q);
      const rows = [];
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
        text: filtering ? "Nothing matches that filter." : "No Scripture references found yet. Write one like (Romans 8:28 ESV) in any note."
      });
    } else if (!filtering) {
      el.createDiv({
        cls: "scripture-index-footnote",
        text: `${index.noteCount} ${index.noteCount === 1 ? "note" : "notes"} with Scripture references`
      });
    }
  }
  /** A collapsible <details> block. Returns the element children go into. */
  section(parent, key, title, count, forceOpen, cls) {
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
  noteRow(parent, path, hits) {
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
  async openAt(path, line, evt) {
    const file = this.app.vault.getAbstractFileByPath(path);
    if (!(file instanceof import_obsidian4.TFile)) return;
    const leaf = this.app.workspace.getLeaf(import_obsidian4.Keymap.isModEvent(evt));
    await leaf.openFile(file, { eState: { line }, active: true });
  }
};
function groupByNote(occ) {
  const out = /* @__PURE__ */ new Map();
  for (const o of occ) {
    const list = out.get(o.path);
    if (!list) out.set(o.path, [o]);
    else if (!list.some((x) => x.line === o.line && x.label === o.label)) list.push(o);
  }
  return new Map([...out.entries()].sort((a, b) => a[0].localeCompare(b[0])));
}

// src/main.ts
var SKIP_READING = "code, pre, a, .internal-link, .scripture-ref, .math, .frontmatter";
var ScriptureLinkerPlugin = class extends import_obsidian5.Plugin {
  constructor() {
    super(...arguments);
    this.cache = {};
  }
  async onload() {
    const data = await this.loadData() ?? {};
    this.settings = { ...DEFAULT_SETTINGS, ...data.settings ?? {} };
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
    await this.saveData({ settings: this.settings, cache: this.cache });
  }
  isExcluded(path) {
    return this.settings.excludedFolders.split(/[\n,]/).map((f) => f.trim().replace(/^\/+|\/+$/g, "")).filter(Boolean).some((f) => path === f || path.startsWith(f + "/"));
  }
  notesOnChapter(bookIndex, chapter) {
    return this.index.notesOnChapter(bookIndex, chapter);
  }
  async openView() {
    const { workspace } = this.app;
    let leaf = workspace.getLeavesOfType(VIEW_TYPE)[0];
    if (!leaf) {
      leaf = workspace.getRightLeaf(false) ?? workspace.getLeaf(true);
      await leaf.setViewState({ type: VIEW_TYPE, active: true });
    }
    await workspace.revealLeaf(leaf);
    return leaf.view instanceof ScriptureIndexView ? leaf.view : null;
  }
  async revealChapter(bookIndex, chapter) {
    const view = await this.openView();
    view?.reveal(bookIndex, chapter);
  }
  registerCommands() {
    this.addCommand({
      id: "open-index",
      name: "Open Scripture Index",
      callback: () => void this.openView()
    });
    this.addCommand({
      id: "show-chapter-at-cursor",
      name: "Show every note on the chapter under the cursor",
      editorCallback: (editor) => {
        const cur = editor.getCursor();
        const line = editor.getLine(cur.line);
        const refs = findReferences(line);
        const ref = refs.find((r) => r.from <= cur.ch && cur.ch <= r.to) ?? refs[0];
        if (!ref) {
          new import_obsidian5.Notice("No Scripture reference on this line.");
          return;
        }
        void this.revealChapter(ref.bookIndex, ref.chapter);
      }
    });
    this.addCommand({
      id: "rebuild-index",
      name: "Rebuild Scripture Index",
      callback: async () => {
        await this.index.rebuild();
        new import_obsidian5.Notice(`Scripture Index rebuilt: ${this.index.noteCount} notes with references.`);
      }
    });
  }
  /** Wrap references in reading view (and hover previews) in a styled span. */
  linkReadingView(el, _ctx) {
    if (!this.settings.decorateReading) return;
    const walker = el.ownerDocument.createTreeWalker(el, NodeFilter.SHOW_TEXT, {
      acceptNode: (node) => node.parentElement?.closest(SKIP_READING) ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT
    });
    const nodes = [];
    for (let n = walker.nextNode(); n; n = walker.nextNode()) nodes.push(n);
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
          createSpan({ cls: "scripture-ref", text: raw, attr: { "data-scripture-ref": raw } })
        );
        last = ref.to;
      }
      frag.append(text.slice(last));
      node.replaceWith(frag);
    }
  }
  registerHover() {
    const refAt = (target) => target instanceof HTMLElement ? target.closest(".scripture-ref") : null;
    if (!import_obsidian5.Platform.isMobile) {
      this.registerDomEvent(document, "mouseover", (evt) => {
        if (!this.settings.showHover) return;
        const el = refAt(evt.target);
        if (el) this.popover.scheduleShow(el);
      });
      this.registerDomEvent(document, "mouseout", (evt) => {
        const from = refAt(evt.target);
        if (!from) return;
        const to = evt.relatedTarget;
        if (this.popover.contains(to) || from.contains(to)) return;
        this.popover.scheduleHide();
      });
    }
    this.registerDomEvent(document, "click", (evt) => {
      const target = evt.target;
      if (this.popover.contains(target)) return;
      const el = refAt(evt.target);
      if (!el) {
        this.popover.hide();
        return;
      }
      const inEditor = !!el.closest(".cm-editor");
      const ref = refFromElement(el);
      if (!ref) return;
      if (import_obsidian5.Platform.isMobile) {
        if (inEditor) return;
        evt.preventDefault();
        this.popover.show(el);
        return;
      }
      if (inEditor && !(evt.metaKey || evt.ctrlKey)) return;
      evt.preventDefault();
      this.popover.hide();
      void this.revealChapter(ref.bookIndex, ref.chapter);
    });
  }
  registerIndexEvents() {
    this.registerEvent(
      this.app.metadataCache.on("changed", (file, data) => this.index.update(file, data))
    );
    this.registerEvent(
      this.app.vault.on("delete", (file) => this.index.remove(file.path))
    );
    this.registerEvent(
      this.app.vault.on("rename", (file, oldPath) => {
        if (file instanceof import_obsidian5.TFile) this.index.rename(file, oldPath);
      })
    );
  }
};
