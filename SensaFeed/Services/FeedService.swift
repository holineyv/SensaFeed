import Foundation

@Observable
final class FeedService {
    var feeds: [Feed] = []
    var sources: [FeedSource] = []
    var isLoading = false
    var errorMessage: String?

    private let parser = RSSParser()
    private let sourcesKey = "savedFeedSources"

    static let defaultSources: [FeedSource] = [
        FeedSource(name: "TechCrunch", url: URL(string: "https://techcrunch.com/feed/")!, category: .tech),
        FeedSource(name: "Ars Technica", url: URL(string: "https://feeds.arstechnica.com/arstechnica/index")!, category: .tech),
        FeedSource(name: "The Verge", url: URL(string: "https://www.theverge.com/rss/index.xml")!, category: .tech),
        FeedSource(name: "BBC News", url: URL(string: "https://feeds.bbci.co.uk/news/rss.xml")!, category: .news),
        FeedSource(name: "Reuters", url: URL(string: "https://www.reutersagency.com/feed/")!, category: .news),
        FeedSource(name: "NASA", url: URL(string: "https://www.nasa.gov/rss/dyn/breaking_news.rss")!, category: .science),
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

    func fetchAllFeeds() async {
        isLoading = true
        errorMessage = nil

        await withTaskGroup(of: Feed?.self) { group in
            for source in sources {
                group.addTask { [parser] in
                    await Self.fetchFeed(from: source.url, parser: parser)
                }
            }

            var results: [Feed] = []
            for await feed in group {
                if let feed {
                    results.append(feed)
                }
            }
            feeds = results
        }

        isLoading = false
    }

    func fetchFeed(for source: FeedSource) async -> Feed? {
        await Self.fetchFeed(from: source.url, parser: parser)
    }

    private static func fetchFeed(from url: URL, parser: RSSParser) async -> Feed? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if var feed = parser.parse(data: data) {
                feed.url = url
                return feed
            }
        } catch {
            // Silently fail for individual feeds
        }
        return nil
    }
}
