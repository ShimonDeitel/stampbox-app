import Foundation
import Combine

@MainActor
final class StampboxStore: ObservableObject {
    @Published private(set) var entries: [StampEntry] = []

    /// Free-tier cap. Deliberately set above the seed-data count so a fresh
    /// install never trips the paywall immediately.
    static let freeLimit = 15

    private let fileName = "stampbox_entries.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    var canAddMore: Bool {
        entries.count < Self.freeLimit
    }

    @discardableResult
    func add(_ entry: StampEntry) -> Bool {
        guard canAddMore else { return false }
        entries.append(entry)
        save()
        return true
    }

    func update(_ entry: StampEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: StampEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func toggleFavorite(_ entry: StampEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx].isFavorite.toggle()
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([StampEntry].self, from: data) {
            entries = decoded
        } else {
            entries = Self.seedData()
            save()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [StampEntry] {
        [
            StampEntry(name: "Penny Black", detail: "United Kingdom", date: Calendar.current.date(byAdding: .day, value: -64000, to: Date()) ?? Date()),
            StampEntry(name: "Inverted Jenny", detail: "United States", date: Calendar.current.date(byAdding: .day, value: -40000, to: Date()) ?? Date()),
            StampEntry(name: "Blue Mauritius", detail: "Mauritius", date: Calendar.current.date(byAdding: .day, value: -60000, to: Date()) ?? Date())
        ]
    }
}
