# Reformation Quest

An 8-bit, Pokémon-style RPG that teaches the history of the Protestant Reformation.
Everything lives in a single dependency-free file: [`index.html`](index.html) — just open it in a browser.

## How to play

1. Open `index.html` in any modern browser (or serve it with `python3 -m http.server`).
2. Choose your reformer: **Martin Luther**, **John Calvin**, or **Ulrich Zwingli** — each with
   historically themed debate moves (95 Theses, Predestination, the Sausage Supper...).
3. Walk the world of 1517. Battles are **theological debates**: wandering indulgence sellers,
   relic peddlers, and friars challenge you in the tall grass.
4. Nail your theses to the **Castle Church** door, then defeat the three great champions of the
   old church — **Johann Tetzel**, **Johann Eck**, and **Cardinal Cajetan** — to unlock the
   finale at the **Diet of Worms**.
5. Optional: meet a fellow reformer at **Marburg Chapel** for a friendly colloquy about the
   Lord's Supper.

### Controls

The game is framed in a Game Boy–style console with a working touch D-pad, A/B buttons, and
START/SELECT — so it plays like a handheld on phones and tablets. On a keyboard:

| Key | Action |
| --- | --- |
| Arrow keys / WASD | D-pad (move) |
| Z / Enter / Space | A — confirm, talk, interact |
| X / Esc | B — back, flee a debate |

Rest at the **inn** (north side of town) to restore your conviction (HP). Losing a debate just
sends you back to the inn to study — no progress is lost.

## What it teaches

- Why indulgences sparked the crisis of 1517, and Tetzel's infamous coin-coffer jingle
- The three "solas" — *sola scriptura*, *sola fide*, *sola gratia*
- Key events: the Leipzig Debate (1519), Cajetan at Augsburg (1518), the Diet of Worms (1521),
  the Marburg Colloquy (1529), the Peace of Augsburg (1555)
- The role of the printing press, vernacular Bibles, and how each reformer's movement differed
- Every battle ends with a **History Lesson** card, and each debate move reveals a real fact
  the first time you use it

The game frames conflict as *debate*, not violence — and a villager will remind you that
"heretic" depended on where you stood.

## Tech

- Pure HTML5 canvas + vanilla JS, no dependencies, no build step
- 240×160 logical resolution upscaled 3× (Game Boy proportions), string-art pixel sprites
- CSS-only Game Boy console shell with pointer-event touch controls (works with touch, pen, and mouse)
- WebAudio square-wave sound effects
- Turn-based battle engine with type effectiveness (grace / scripture / conviction),
  XP, levels, and boss-gated progression
