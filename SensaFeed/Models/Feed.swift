import Foundation

struct Feed: Identifiable, Hashable {
    let id: UUID
    var title: String
    var url: URL
    var description: String
    var imageURL: URL?
    var items: [FeedItem]

    init(title: String, url: URL, description: String = "", imageURL: URL? = nil, items: [FeedItem] = []) {
        self.id = UUID()
        self.title = title
        self.url = url
        self.description = description
        self.imageURL = imageURL
        self.items = items
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Feed, rhs: Feed) -> Bool {
        lhs.id == rhs.id
    }
}

struct FeedItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var link: URL?
    var description: String
    var pubDate: Date?
    var author: String?
    var imageURL: URL?

    init(title: String, link: URL? = nil, description: String = "", pubDate: Date? = nil, author: String? = nil, imageURL: URL? = nil) {
        self.id = UUID()
        self.title = title
        self.link = link
        self.description = description
        self.pubDate = pubDate
        self.author = author
        self.imageURL = imageURL
    }
}
