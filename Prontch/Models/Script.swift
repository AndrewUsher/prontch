import Foundation

struct Script: Identifiable, Codable {
    let id: UUID
    var content: String
    var createdAt: Date
    var name: String

    init(id: UUID = UUID(), content: String, name: String = "Untitled Script") {
        self.id = id
        self.content = content
        self.createdAt = Date()
        self.name = name
    }

    var paragraphs: [String] {
        content.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
