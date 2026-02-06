import SwiftUI

struct FeedListView: View {
    @Environment(FeedService.self) private var feedService
    @State private var showingAddFeed = false

    var body: some View {
        NavigationStack {
            Group {
                if feedService.isLoading && feedService.feeds.isEmpty {
                    ProgressView("Loading feeds...")
                } else if feedService.sources.isEmpty {
                    ContentUnavailableView(
                        "No Feeds",
                        systemImage: "newspaper",
                        description: Text("Add RSS feeds to start reading")
                    )
                } else {
                    List {
                        ForEach(FeedCategory.allCases) { category in
                            let categorySources = feedService.sources.filter { $0.category == category }
                            if !categorySources.isEmpty {
                                Section(category.rawValue) {
                                    ForEach(categorySources) { source in
                                        NavigationLink(value: source) {
                                            FeedSourceRow(source: source, feed: feedFor(source))
                                        }
                                    }
                                    .onDelete { offsets in
                                        deleteSources(categorySources, at: offsets)
                                    }
                                }
                            }
                        }
                    }
                    .refreshable {
                        await feedService.fetchAllFeeds()
                    }
                }
            }
            .navigationTitle("SensaFeed")
            .navigationDestination(for: FeedSource.self) { source in
                ArticleListView(source: source)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        if !feedService.sources.isEmpty {
                            EditButton()
                        }
                        Button {
                            showingAddFeed = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        AllArticlesView()
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .sheet(isPresented: $showingAddFeed) {
                AddFeedView()
            }
            .task {
                if feedService.feeds.isEmpty {
                    await feedService.fetchAllFeeds()
                }
            }
        }
    }

    private func feedFor(_ source: FeedSource) -> Feed? {
        feedService.feeds.first { $0.url == source.url }
    }

    private func deleteSources(_ categorySources: [FeedSource], at offsets: IndexSet) {
        for index in offsets {
            feedService.removeSource(categorySources[index])
        }
    }
}

struct FeedSourceRow: View {
    let source: FeedSource
    let feed: Feed?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: source.category.systemImage)
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(source.name)
                    .font(.headline)
                if let feed, !feed.items.isEmpty {
                    Text("\(feed.items.count) articles")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
