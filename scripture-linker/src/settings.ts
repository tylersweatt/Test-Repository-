import { App, Notice, PluginSettingTab, Setting } from "obsidian";
import type ScriptureLinkerPlugin from "./main";

export interface ScriptureLinkerSettings {
	esvApiKey: string;
	showHover: boolean;
	hoverDelay: number;
	decorateEditor: boolean;
	decorateReading: boolean;
	excludedFolders: string;
}

export const DEFAULT_SETTINGS: ScriptureLinkerSettings = {
	esvApiKey: "",
	showHover: true,
	hoverDelay: 300,
	decorateEditor: true,
	decorateReading: true,
	excludedFolders: "",
};

export class ScriptureLinkerSettingTab extends PluginSettingTab {
	constructor(app: App, private plugin: ScriptureLinkerPlugin) {
		super(app, plugin);
	}

	display() {
		const { containerEl } = this;
		containerEl.empty();
		const s = this.plugin.settings;
		const save = () => void this.plugin.save();

		new Setting(containerEl).setName("ESV text").setHeading();

		const keyDesc = createFragment((f) => {
			f.appendText("Needed to show verse text on hover. Get a free key at ");
			f.createEl("a", { text: "api.esv.org", href: "https://api.esv.org/account/create-application/" });
			f.appendText(". Without one, references are still linked and indexed.");
		});
		new Setting(containerEl)
			.setName("ESV API key")
			.setDesc(keyDesc)
			.addText((t) => {
				t.inputEl.type = "password";
				t.setPlaceholder("Paste your key").setValue(s.esvApiKey).onChange((v) => {
					s.esvApiKey = v.trim();
					save();
				});
			});

		new Setting(containerEl)
			.setName("Clear saved verses")
			.setDesc("Passages are cached so hovering is instant. The cache keeps the last 100.")
			.addButton((b) =>
				b.setButtonText("Clear").onClick(() => {
					this.plugin.esv.clear();
					new Notice("Saved verses cleared.");
				}),
			);

		new Setting(containerEl).setName("Links").setHeading();

		new Setting(containerEl)
			.setName("Show verse on hover")
			.addToggle((t) => t.setValue(s.showHover).onChange((v) => {
				s.showHover = v;
				save();
			}));

		new Setting(containerEl)
			.setName("Hover delay")
			.setDesc("Milliseconds before the verse card appears.")
			.addSlider((sl) =>
				sl.setLimits(0, 1000, 50).setValue(s.hoverDelay).setDynamicTooltip().onChange((v) => {
					s.hoverDelay = v;
					save();
				}),
			);

		new Setting(containerEl)
			.setName("Link references in the editor")
			.setDesc("Ctrl/Cmd-click a reference to see every note on that chapter. Takes effect after reloading Obsidian.")
			.addToggle((t) => t.setValue(s.decorateEditor).onChange((v) => {
				s.decorateEditor = v;
				save();
			}));

		new Setting(containerEl)
			.setName("Link references in reading view")
			.addToggle((t) => t.setValue(s.decorateReading).onChange((v) => {
				s.decorateReading = v;
				save();
			}));

		new Setting(containerEl).setName("Index").setHeading();

		new Setting(containerEl)
			.setName("Excluded folders")
			.setDesc("One per line. Notes here are left out of the Scripture Index, e.g. Templates.")
			.addTextArea((t) =>
				t.setValue(s.excludedFolders).onChange((v) => {
					s.excludedFolders = v;
					save();
				}),
			)
			.addButton((b) =>
				b.setButtonText("Rebuild index").onClick(async () => {
					await this.plugin.index.rebuild();
					new Notice(`Scripture Index rebuilt: ${this.plugin.index.noteCount} notes with references.`);
				}),
			);
	}
}
