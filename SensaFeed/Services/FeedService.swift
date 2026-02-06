import Foundation

@Observable
final class FeedService {
    var feeds: [Feed] = []
    var sources: [FeedSource] = []
    var isLoading = false
    var errorMessage: String?

    private let parser = RSSParser()
    private let sourcesKey = "savedFeedSources"

    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 20
        return URLSession(configuration: config)
    }()

    static let defaultSources: [FeedSource] = [
        FeedSource(name: "Ars Technica", url: URL(string: "https://feeds.arstechnica.com/arstechnica/index")!, category: .tech),
        FeedSource(name: "BBC News", url: URL(string: "https://feeds.bbci.co.uk/news/rss.xml")!, category: .news),
    ]

    init() {
        loadSources()
    }

    func loadSources() {
        if let data = UserDefaults.standard.data(forKey: sourcesKey),
           let saved = try? JSONDecoder().decode([FeedSource].self, from: data) {
            sources = saved
        } else {
            sources = Self.defaultSources
        }
    }

    func saveSources() {
        if let data = try? JSONEncoder().encode(sources) {
            UserDefaults.standard.set(data, forKey: sourcesKey)
        }
    }

    func addSource(_ source: FeedSource) {
        sources.append(source)
        saveSources()
    }

    func removeSource(_ source: FeedSource) {
        sources.removeAll { $0.id == source.id }
        feeds.removeAll { $0.url == source.url }
        saveSources()
    }

    func resetToDefaults() {
        UserDefaults.standard.removeObject(forKey: sourcesKey)
        sources = Self.defaultSources
        feeds = []
    }

    func fetchAllFeeds() async {
        isLoading = true
        errorMessage = nil

        await withTaskGroup(of: Feed?.self) { group in
            for source in sources {
                group.addTask { [parser] in
                    await Self.fetchFeed(from: source.url, parser: parser)
                }
            }

            // Show feeds incrementally as they arrive
            for await feed in group {
                if let feed {
                    if let index = feeds.firstIndex(where: { $0.url == feed.url }) {
                        feeds[index] = feed
                    } else {
                        feeds.append(feed)
                    }
                }
            }
        }

        isLoading = false
    }

    func fetchFeed(for source: FeedSource) async -> Feed? {
        await Self.fetchFeed(from: source.url, parser: parser)
    }

    private static func fetchFeed(from url: URL, parser: RSSParser) async -> Feed? {
        do {
            let (data, _) = try await session.data(from: url)
            if var feed = parser.parse(data: data) {
                feed.url = url
                return feed
            }
        } catch {
            // Individual feed failure — skip silently
        }
        return nil
    }
}
