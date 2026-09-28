import { test } from "node:test";
import assert from "node:assert/strict";
import { findReferences, formatRef, chaptersOf, maskCode } from "../src/parser";

const labels = (s: string) => findReferences(s).map((r) => formatRef(r));

test("the house citation format", () => {
	assert.deepEqual(labels("God works all things (Romans 8:28 ESV)."), ["Romans 8:28"]);
	const [r] = findReferences("(Romans 8:28 ESV)");
	assert.equal(r.version, "ESV");
	assert.equal("(Romans 8:28 ESV)".slice(r.from, r.to), "Romans 8:28 ESV");
});

test("ranges and lists", () => {
	assert.deepEqual(labels("Romans 8:28-30"), ["Romans 8:28–30"]);
	assert.deepEqual(labels("Romans 8:28–9:4"), ["Romans 8:28–9:4"]);
	assert.deepEqual(labels("Romans 8-9"), ["Romans 8–9"]);
	assert.deepEqual(labels("Romans 8:28, 31, 35-37 and more"), ["Romans 8:28, 31, 35–37"]);
	assert.deepEqual(labels("Rom 8:28, 1 Cor 2:9"), ["Romans 8:28", "1 Corinthians 2:9"]);
	assert.deepEqual(chaptersOf(findReferences("Rom 8:28-9:4")[0]), [8, 9]);
});

test("abbreviations and numbered books", () => {
	assert.deepEqual(labels("1 John 4:1"), ["1 John 4:1"]);
	assert.deepEqual(labels("1Cor 13"), ["1 Corinthians 13"]);
	assert.deepEqual(labels("First Peter 2:9"), ["1 Peter 2:9"]);
	assert.deepEqual(labels("II Tim. 3:16"), ["2 Timothy 3:16"]);
	assert.deepEqual(labels("Ps 23"), ["Psalms 23"]);
	assert.deepEqual(labels("Psalm 119:105"), ["Psalms 119:105"]);
	assert.deepEqual(labels("Gen. 1:1"), ["Genesis 1:1"]);
	assert.deepEqual(labels("John 3:16"), ["John 3:16"]);
	assert.deepEqual(labels("Song of Songs 2:4"), ["Song of Solomon 2:4"]);
});

test("single-chapter books", () => {
	assert.deepEqual(labels("Jude 3"), ["Jude 3"]);
	assert.deepEqual(labels("Jude 1:24-25"), ["Jude 24–25"]);
	assert.deepEqual(labels("Philemon 6"), ["Philemon 6"]);
});

test("things that are not references", () => {
	assert.deepEqual(labels("Song 2: Amazing Grace"), []);
	assert.deepEqual(labels("Romans 17"), []);
	assert.deepEqual(labels("Mark 5th"), []);
	assert.deepEqual(labels("Act 2 opens"), []);
	assert.deepEqual(labels("Is 5 enough?"), []);
	assert.deepEqual(labels("romans 8:28"), []);
	assert.deepEqual(labels("Johnson 3:16"), []);
});

test("code is masked", () => {
	const text = "See `Romans 8:28` and\n```\nJohn 3:16\n```\nEph 2:8";
	const masked = maskCode(text);
	assert.equal(masked.length, text.length);
	assert.deepEqual(labels(masked), ["Ephesians 2:8"]);
});
