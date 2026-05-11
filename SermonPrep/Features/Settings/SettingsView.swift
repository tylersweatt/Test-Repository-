import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Preacher") {
                TextField("Your Name", text: $settings.preacherName)
            }

            Section("Scripture") {
                Picker("Default Translation", selection: $settings.defaultTranslation) {
                    ForEach(["KJV", "ESV", "NIV", "CSB", "NKJV", "NLT", "NASB"], id: \.self) { t in
                        Text(t).tag(t)
                    }
                }
            }

            Section {
                HStack {
                    TextField("ESV API Key", text: $settings.esvApiKey)
                        .textContentType(.password)
                        #if os(iOS)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        #endif
                    if settings.hasESVKey {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                Link("Get a free key at api.esv.org", destination: URL(string: "https://api.esv.org/account/create-application/")!)
                    .font(.caption)
            } header: {
                Text("ESV Bible")
            } footer: {
                Text("Your key is stored on-device and used only to fetch ESV verse text in the scripture picker. Crossway provides free keys for personal use.")
                    .font(.caption)
            }

            Section {
                Toggle("Use API.Bible (other translations)", isOn: $settings.useBibleAPI)
                if settings.useBibleAPI {
                    TextField("API.Bible Key", text: $settings.bibleAPIKey)
                        .textContentType(.password)
                    Text("Get a free key at api.bible")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Other Translations (NIV, CSB, NKJV)")
            }

            Section("Appearance") {
                Picker("Color Scheme", selection: $settings.preferredColorScheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
            }

            Section("Presentation") {
                HStack {
                    Text("Teleprompter Speed")
                    Spacer()
                    Text("\(Int(settings.teleprompterSpeed)) wpm")
                        .foregroundStyle(.secondary)
                }
                Slider(value: $settings.teleprompterSpeed, in: 10...200, step: 5)
            }

            Section("Export") {
                Picker("Export Font", selection: $settings.exportFont) {
                    Text("Georgia").tag("Georgia")
                    Text("Helvetica").tag("Helvetica")
                    Text("Times New Roman").tag("Times New Roman")
                    Text("Palatino").tag("Palatino")
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("iCloud Sync")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        #endif
    }
}
