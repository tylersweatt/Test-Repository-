export interface Book {
	name: string;
	chapters: number;
	aliases: string[];
}

// Canonical Protestant order. Aliases are the common abbreviations people type
// in notes; numbered books get their prefixes expanded in `buildAliasMap()`.
// Abbreviations that are also ordinary words ("Is", "Am", "Song", "Act") are
// left out on purpose so "Song 2" in a setlist doesn't become Song of Solomon.
const OT: Book[] = [
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
	{ name: "Malachi", chapters: 4, aliases: ["Mal"] },
];

const NT: Book[] = [
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
	{ name: "Revelation", chapters: 22, aliases: ["Rev", "Rv", "Revelations"] },
];

export const BOOKS: Book[] = [...OT, ...NT];

const PREFIXES: Record<string, string[]> = {
	"1": ["1", "1st", "First", "I"],
	"2": ["2", "2nd", "Second", "II"],
	"3": ["3", "3rd", "Third", "III"],
};

/** Every spelling a note might use, mapped to its book's index in BOOKS. */
export function buildAliasMap(): Map<string, number> {
	const map = new Map<string, number>();
	BOOKS.forEach((book, i) => {
		const m = /^([123]) (.+)$/.exec(book.name);
		if (m) {
			const stems = [m[2], ...book.aliases];
			for (const prefix of PREFIXES[m[1]]) {
				for (const stem of stems) {
					map.set(`${prefix} ${stem}`, i);
					// "1Cor", "1John" — only for digit prefixes
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
