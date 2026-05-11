import SwiftUI
import SwiftData

// MARK: - TemplateListView

struct TemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var templates: [SermonTemplate]
    @State private var isShowingNewTemplate = false

    var systemTemplates: [SermonTemplate] { templates.filter { $0.isSystemTemplate } }
    var userTemplates: [SermonTemplate] { templates.filter { !$0.isSystemTemplate } }

    var body: some View {
        List {
            if !systemTemplates.isEmpty {
                Section("Built-In Templates") {
                    ForEach(systemTemplates) { template in
                        TemplateRow(template: template)
                    }
                }
            }

            Section("My Templates") {
                if userTemplates.isEmpty {
                    Text("No custom templates yet.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(userTemplates) { template in
                        TemplateRow(template: template)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    modelContext.delete(template)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle("Templates")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingNewTemplate = true
                } label: {
                    Label("New Template", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingNewTemplate) {
            NewTemplateSheet()
        }
    }
}

// MARK: - TemplateRow

struct TemplateRow: View {
    let template: SermonTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(template.title)
                    .font(.headline)
                if template.isSystemTemplate {
                    Text("Built-In")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.15))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
            if !template.templateDescription.isEmpty {
                Text(template.templateDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            let blockTypes = template.blockTypes
            if !blockTypes.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(blockTypes) { type in
                            Image(systemName: type.systemImage)
                                .font(.caption2)
                                .foregroundStyle(type.accentColor)
                                .padding(4)
                                .background(type.accentColor.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - NewTemplateSheet

struct NewTemplateSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var selectedBlockTypes: [BlockType] = [.hook, .scripture, .outline, .explanation, .application, .conclusion]

    var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty && !selectedBlockTypes.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Template") {
                    TextField("Name", text: $title)
                    TextField("Description (optional)", text: $description)
                }
                Section("Block Sequence") {
                    ForEach(selectedBlockTypes) { type in
                        Label(type.displayName, systemImage: type.systemImage)
                            .foregroundStyle(type.accentColor)
                    }
                    .onMove { from, to in
                        selectedBlockTypes.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { offsets in
                        selectedBlockTypes.remove(atOffsets: offsets)
                    }

                    Menu {
                        ForEach(BlockType.allCases) { type in
                            Button {
                                if !selectedBlockTypes.contains(type) {
                                    selectedBlockTypes.append(type)
                                }
                            } label: {
                                Label(type.displayName, systemImage: type.systemImage)
                            }
                        }
                    } label: {
                        Label("Add Block Type", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("New Template")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTemplate() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func saveTemplate() {
        let template = SermonTemplate(
            title: title.trimmingCharacters(in: .whitespaces),
            blockTypes: selectedBlockTypes,
            isSystem: false
        )
        template.templateDescription = description
        modelContext.insert(template)
        dismiss()
    }
}
