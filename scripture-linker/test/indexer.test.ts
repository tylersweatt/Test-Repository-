import { test } from "node:test";
import assert from "node:assert/strict";
import { TFile, Vault } from "obsidian";
import { BOOKS } from "../src/books";
import { extractOccurrences, ScriptureIndex } from "../src/indexer";

const ROMANS = BOOKS.findIndex((b) => b.name === "Romans");

const note = `---
passage: Romans 8:28-30
---
# Sermon notes

God works all things together for good (Romans 8:28 ESV).
Compare Gen 50:20 and Rom 9:1.

\`\`\`
John 3:16 in a code block is ignored
\`\`\`
`;

test("occurrences carry line numbers and snippets", () => {
	const occ = extractOccurrences("Sermons/Romans 8.md", note);
	assert.deepEqual(
		occ.map((o) => [o.label, o.line]),
		[["Romans 8:28–30", 1], ["Romans 8:28", 5], ["Genesis 50:20", 6], ["Romans 9:1", 6]],
	);
	assert.equal(occ[1].snippet, "God works all things together for good (Romans 8:28 ESV).");
});

test("index groups by book and chapter and follows edits", () => {
	const index = new ScriptureIndex(new Vault() as never, (p) => p.startsWith("Templates/"));
	let changes = 0;
	index.on("changed", () => changes++);

	index.update(new TFile("a.md") as never, note);
	index.update(new TFile("b.md") as never, "Paul again in Romans 8:1.");
	index.update(new TFile("Templates/t.md") as never, "Romans 8:1");

	assert.equal(index.notesOnChapter(ROMANS, 8), 2, "excluded folder is skipped");
	assert.equal(index.notesOnChapter(ROMANS, 9), 1);
	assert.equal(changes, 2);

	// Re-saving with no reference changes doesn't re-render the panel.
	index.update(new TFile("b.md") as never, "Paul again in Romans 8:1.");
	assert.equal(changes, 2);

	index.update(new TFile("b.md") as never, "Nothing here now.");
	assert.equal(index.notesOnChapter(ROMANS, 8), 1);

	const romans = index.grouped().get(ROMANS)!;
	assert.deepEqual([...romans.keys()].sort((a, b) => a - b), [8, 9]);

	index.remove("a.md");
	assert.equal(index.noteCount, 0);
});
