import Foundation

struct FeedSource: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var url: URL
    var category: FeedCategory

    init(name: String, url: URL, category: FeedCategory = .general) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.category = category
    }
}

enum FeedCategory: String, Codable, CaseIterable, Identifiable {
    case tech = "Tech"
    case news = "News"
    case science = "Science"
    case health = "Health"
    case entertainment = "Entertainment"
    case general = "General"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .tech: return "laptopcomputer"
        case .news: return "newspaper"
        case .science: return "atom"
        case .health: return "heart"
        case .entertainment: return "film"
        case .general: return "globe"
        }
    }
}
