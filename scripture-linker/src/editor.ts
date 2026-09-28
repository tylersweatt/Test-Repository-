import { syntaxTree } from "@codemirror/language";
import { RangeSetBuilder } from "@codemirror/state";
import { Decoration, DecorationSet, EditorView, ViewPlugin, ViewUpdate } from "@codemirror/view";
import { findReferences } from "./parser";

// Obsidian's markdown node names for places a reference shouldn't be styled.
const SKIP_NODE = /code|link|url|math|comment|hashtag|frontmatter/i;

function build(view: EditorView): DecorationSet {
	const builder = new RangeSetBuilder<Decoration>();
	const tree = syntaxTree(view.state);
	const doc = view.state.doc;

	for (const { from, to } of view.visibleRanges) {
		// Scan whole lines so a reference cut off at the viewport edge still matches.
		const start = doc.lineAt(from).from;
		const end = doc.lineAt(to).to;
		const text = doc.sliceString(start, end);
		for (const ref of findReferences(text)) {
			const a = start + ref.from;
			const b = start + ref.to;
			let skip = false;
			for (let node: ReturnType<typeof tree.resolveInner> | null = tree.resolveInner(a, 1); node; node = node.parent) {
				if (SKIP_NODE.test(node.name)) {
					skip = true;
					break;
				}
			}
			if (skip) continue;
			builder.add(
				a,
				b,
				Decoration.mark({
					class: "scripture-ref",
					attributes: { "data-scripture-ref": text.slice(ref.from, ref.to) },
				}),
			);
		}
	}
	return builder.finish();
}

export const scriptureEditorExtension = ViewPlugin.fromClass(
	class {
		decorations: DecorationSet;

		constructor(view: EditorView) {
			this.decorations = build(view);
		}

		update(u: ViewUpdate) {
			if (u.docChanged || u.viewportChanged || syntaxTree(u.startState) !== syntaxTree(u.state)) {
				this.decorations = build(u.view);
			}
		}
	},
	{ decorations: (v) => v.decorations },
);
