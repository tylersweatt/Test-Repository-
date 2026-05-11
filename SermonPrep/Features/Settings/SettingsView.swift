import SwiftUI

// MARK: - SettingsView

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
                    ForEach(["KJV", "NIV", "ESV", "NKJV", "NLT", "NASB", "CSB", "MSG"], id: \.self) { t in
                        Text(t).tag(t)
                    }
                }
                Toggle("Use Bible API for Lookups", isOn: $settings.useBibleAPI)
                if settings.useBibleAPI {
                    TextField("API Key", text: $settings.bibleAPIKey)
                        .textContentType(.password)
                    TextField("Bible ID (API.Bible)", text: $settings.apiBibleID)
                }
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
                    Slider(value: $settings.teleprompterSpeed, in: 10...100, step: 5)
                        .frame(maxWidth: 200)
                    Text("\(Int(settings.teleprompterSpeed))")
                        .foregroundStyle(.secondary)
                        .frame(width: 36)
                }
            }

            Section("Export") {
                Picker("Export Font", selection: $settings.exportFont) {
                    Text("Georgia").tag("Georgia")
                    Text("Helvetica").tag("Helvetica")
                    Text("Times New Roman").tag("Times New Roman")
                    Text("System").tag("System")
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                        .foregroundStyle(.secondary)
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
