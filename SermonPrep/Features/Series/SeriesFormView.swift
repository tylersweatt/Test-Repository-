import SwiftUI

struct SeriesFormView: View {
    var onSave: (Series) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var hasStartDate = false

    var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Series") {
                    TextField("Series Title", text: $title)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Dates") {
                    Toggle("Has Start Date", isOn: $hasStartDate)
                    if hasStartDate {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Series")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let series = Series(title: title.trimmingCharacters(in: .whitespaces))
                        series.sermonDescription = description.isEmpty ? nil : description
                        series.startDate = hasStartDate ? startDate : nil
                        onSave(series)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
