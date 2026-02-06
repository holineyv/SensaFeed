import SwiftUI

struct AllArticlesView: View {
    @Environment(FeedService.self) private var feedService

    private var allItems: [(FeedItem, String)] {
        feedService.feeds.flatMap { feed in
            feed.items.map { ($0, feed.title) }
        }
        .sorted { a, b in
            (a.0.pubDate ?? .distantPast) > (b.0.pubDate ?? .distantPast)
        }
    }

    var body: some View {
        List(allItems, id: \.0.id) { item, feedTitle in
            NavigationLink(value: item) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(feedTitle)
                        .font(.caption)
                        .foregroundStyle(.tint)
                        .textCase(.uppercase)

                    Text(item.title)
                        .font(.headline)
                        .lineLimit(2)

                    if !item.description.isEmpty {
                        Text(item.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    if let date = item.pubDate {
                        Text(date, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("All Articles")
        .navigationDestination(for: FeedItem.self) { item in
            ArticleDetailView(item: item)
        }
    }
}
