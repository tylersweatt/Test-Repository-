import SwiftUI
import SwiftData

struct TemplateListView: View {
    @Query private var templates: [SermonTemplate]
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var isShowingNewTemplate = false
    @State private var selectedTemplate: SermonTemplate? = nil

    var systemTemplates: [SermonTemplate] { templates.filter { $0.isSystemTemplate } }
    var userTemplates: [SermonTemplate] { templates.filter { !$0.isSystemTemplate } }

    var body: some View {
        List {
            if !systemTemplates.isEmpty {
                Section("Built-in Templates") {
                    ForEach(systemTemplates) { template in
                        templateRow(template)
                    }
                }
            }
            if !userTemplates.isEmpty {
                Section("My Templates") {
                    ForEach(userTemplates) { template in
                        templateRow(template)
                    }
                    .onDelete { offsets in
                        for i in offsets { modelContext.delete(userTemplates[i]) }
                    }
                }
            }
        }
        .navigationTitle("Templates")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { isShowingNewTemplate = true } label: {
                    Label("New Template", systemImage: "plus")
                }
            }
        }
        .sheet(item: $selectedTemplate) { template in
            NewSermonFromTemplateSheet(template: template)
        }
        .sheet(isPresented: $isShowingNewTemplate) {
            NewTemplateSheet()
        }
        .overlay {
            if templates.isEmpty {
                ContentUnavailableView("No Templates", systemImage: "square.grid.2x2")
            }
        }
    }

    func templateRow(_ template: SermonTemplate) -> some View {
        VStack(alignment: .leading, spacing: 6) {
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
                    .lineLimit(2)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(template.blockTypes.prefix(8), id: \.self) { type in
                        Image(systemName: type.systemImage)
                            .font(.caption2)
                            .foregroundStyle(type.accentColor)
                            .padding(4)
                            .background(type.accentColor.opacity(0.1))
                            .clipShape(Circle())
                    }
                    if template.blockTypes.count > 8 {
                        Text("+\(template.blockTypes.count - 8)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture { selectedTemplate = template }
    }
}

// MARK: - NewSermonFromTemplateSheet

struct NewSermonFromTemplateSheet: View {
    let template: SermonTemplate
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var title = ""
    @State private var passageReference = ""
    @State private var selectedBook: BibleBook = .john

    var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Based on: \(template.title)") {
                    TextField("Sermon Title", text: $title)
                    TextField("Passage Reference", text: $passageReference)
                    Picker("Book of Bible", selection: $selectedBook) {
                        ForEach(BibleBook.allCases) { book in
                            Text(book.rawValue).tag(book)
                        }
                    }
                }
            }
            .navigationTitle("New Sermon")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createFromTemplate() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func createFromTemplate() {
        let sermon = Sermon(
            title: title.trimmingCharacters(in: .whitespaces),
            passageReference: passageReference,
            bookOfBible: selectedBook
        )
        modelContext.insert(sermon)
        for (i, blockType) in template.blockTypes.enumerated() {
            let block = SermonBlock(blockType: blockType, sortOrder: i, sermon: sermon)
            modelContext.insert(block)
            sermon.blocks.append(block)
        }
        appState.selectedSermonID = sermon.id
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - NewTemplateSheet

struct NewTemplateSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var selectedBlockTypes: [BlockType] = [
        .hook, .scripture, .outline, .explanation, .application, .conclusion
    ]

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !selectedBlockTypes.isEmpty
    }

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
                                selectedBlockTypes.append(type)
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
