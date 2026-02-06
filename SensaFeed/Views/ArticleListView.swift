import SwiftUI

struct ArticleListView: View {
    @Environment(FeedService.self) private var feedService
    let source: FeedSource
    @State private var feed: Feed?
    @State private var isLoading = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if let feed, !feed.items.isEmpty {
                List(feed.items) { item in
                    NavigationLink(value: item) {
                        ArticleRow(item: item)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Articles",
                    systemImage: "doc.text",
                    description: Text("Could not load articles from this feed")
                )
            }
        }
        .navigationTitle(source.name)
        .navigationDestination(for: FeedItem.self) { item in
            ArticleDetailView(item: item)
        }
        .task {
            feed = feedService.feeds.first { $0.url == source.url }
            if feed == nil {
                isLoading = true
                feed = await feedService.fetchFeed(for: source)
                isLoading = false
            }
        }
    }
}

struct ArticleRow: View {
    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.title)
                .font(.headline)
                .lineLimit(2)

            if !item.description.isEmpty {
                Text(item.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            HStack {
                if let author = item.author {
                    Text(author)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                if let date = item.pubDate {
                    Text(date, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
