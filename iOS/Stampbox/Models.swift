import Foundation

struct StampEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var detail: String
    var date: Date
    var isFavorite: Bool = false
    var notes: String = ""
    var createdAt: Date = Date()
}
