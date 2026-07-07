import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: StampboxStore
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: StampEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.mutedText)
                        Text("No stamps yet")
                            .font(AppTheme.headlineFont)
                            .foregroundColor(AppTheme.mutedText)
                    }
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            Button {
                                editingEntry = entry
                            } label: {
                                row(for: entry)
                            }
                            .listRowBackground(AppTheme.card)
                            .accessibilityIdentifier("entryRow_\(entry.name)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Stampbox")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryEditorView(entry: nil) { new in
                    store.add(new)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditorView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    @ViewBuilder
    private func row(for entry: StampEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.primaryText)
                Text(entry.detail)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.mutedText)
                Text(entry.date, style: .date)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondary)
            }
            Spacer()
            if entry.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(AppTheme.accent)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryEditorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    @State private var detail: String
    @State private var date: Date
    @State private var isFavorite: Bool

    let existing: StampEntry?
    let onSave: (StampEntry) -> Void

    init(entry: StampEntry?, onSave: @escaping (StampEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _name = State(initialValue: entry?.name ?? "")
        _detail = State(initialValue: entry?.detail ?? "")
        _date = State(initialValue: entry?.date ?? Date())
        _isFavorite = State(initialValue: entry?.isFavorite ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Stamp") {
                    TextField("Name", text: $name)
                        .accessibilityIdentifier("entryNameField")
                    TextField("Country", text: $detail)
                        .accessibilityIdentifier("entryDetailField")
                    DatePicker("Issue Year (approx.)", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("entryDatePicker")
                    Toggle("Favorite", isOn: $isFavorite)
                        .accessibilityIdentifier("entryFavoriteToggle")
                }
            }
            .navigationTitle(existing == nil ? "Add Stamp" : "Edit Stamp")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("entryCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var entry = existing ?? StampEntry(name: name, detail: detail, date: date)
                        entry.name = name
                        entry.detail = detail
                        entry.date = date
                        entry.isFavorite = isFavorite
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("entrySaveButton")
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
