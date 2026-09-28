import esbuild from "esbuild";
import { builtinModules } from "node:module";

const watch = process.argv.includes("--watch");

const ctx = await esbuild.context({
	entryPoints: ["src/main.ts"],
	bundle: true,
	// Obsidian supplies these at runtime.
	external: ["obsidian", "electron", "@codemirror/*", "@lezer/*", ...builtinModules],
	format: "cjs",
	target: "es2020",
	platform: "browser",
	logLevel: "info",
	sourcemap: watch ? "inline" : false,
	treeShaking: true,
	outfile: "main.js",
});

if (watch) await ctx.watch();
else {
	await ctx.rebuild();
	await ctx.dispose();
}
