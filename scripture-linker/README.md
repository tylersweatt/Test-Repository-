# Scripture Linker for Obsidian

Finds Bible references in your notes, shows the ESV text when you hover, and keeps an index of every note by book and chapter.

Write `(Romans 8:28 ESV)` the way you already do. The reference turns into a link. Hover it to read the verse. Click it to see every other note where you've touched Romans 8.

## What it does

- **Recognizes references** like `Romans 8:28`, `Rom 8:28-30`, `Romans 8:28–9:4`, `Romans 8-9`, `Rom 8:28, 31, 35-37`, `1 Cor 13`, `First Peter 2:9`, `Ps 23`, and `Jude 3`. A trailing `ESV` (or KJV, NASB, and so on) is included in the link. References inside code blocks and existing links are ignored.
- **Hover to read.** A card shows the passage in the ESV. It also has a button for every note on that chapter and a link to esv.org. On a phone, tap a reference in reading view.
- **Scripture Index panel.** Opens in the right sidebar. The top shows the references in the note you have open. Below that, every book of the Bible you've referenced, in canonical order, then each chapter, then each note with the line where it shows up. Click a line to jump straight there. Filter by typing `Romans 8`, `Psalms`, or part of a note's name.
- **Clicking a reference** in reading view opens the index at that chapter. In the editor, use Ctrl-click (Cmd-click on Mac) so a normal click still places the cursor.

Nothing in your notes gets rewritten. The links are drawn on top of your text.

## Install

1. In your vault, create the folder `.obsidian/plugins/scripture-linker/`.
2. Copy `main.js`, `manifest.json`, and `styles.css` from this folder into it.
3. In Obsidian, open **Settings → Community plugins**, turn off Restricted mode if it's on, and enable **Scripture Linker**.

For iPhone or iPad, copy the same three files into that folder inside your vault in the Files app (or let Obsidian Sync or iCloud carry them over from your Mac).

## Get verse text on hover

The ESV text comes from Crossway's free ESV API.

1. Create an account and an application at https://api.esv.org/account/create-application/ (non-commercial use is free).
2. Copy the API key.
3. Paste it into **Settings → Scripture Linker → ESV API key**.

Without a key, everything still works except the verse text in the hover card. The plugin keeps the last 100 passages you've looked at so hovering is instant and works offline. The ESV API's terms limit how much text an app can store, which is why the cache stays small.

## Commands

- **Open Scripture Index**
- **Show every note on the chapter under the cursor**
- **Rebuild Scripture Index**

## Settings

- ESV API key
- Show verse on hover, and the hover delay
- Link references in the editor and in reading view
- Excluded folders, one per line (for example `Templates`), left out of the index

## Development

```sh
npm install
npm run dev     # rebuilds main.js on save
npm run build   # typecheck and build
npm test        # parser and index tests
```

The code lives in `src/`:

| File | What it does |
| --- | --- |
| `books.ts` | The 66 books, chapter counts, and accepted abbreviations |
| `parser.ts` | Finds references in text and formats them |
| `indexer.ts` | Keeps the vault-wide book → chapter → note index current |
| `esv.ts` | Fetches and caches passages from the ESV API |
| `editor.ts` | Underlines references in the editor |
| `popover.ts` | The hover card |
| `view.ts` | The Scripture Index side panel |
| `main.ts` | Wires it all together |

A few abbreviations that are also everyday words (`Is`, `Am`, `Song`, `Act`) are left out on purpose, so "Song 2" in a setlist doesn't turn into Song of Solomon. Spell those books out or use `Isa`, `Amos`, `Song of Songs`, and `Acts`.
