import SwiftUI
import WebKit

struct ArticleDetailView: View {
    let item: FeedItem

    var body: some View {
        Group {
            if let url = item.link {
                WebView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(item.title)
                            .font(.title)

                        if let date = item.pubDate {
                            Text(date, style: .date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Text(item.description)
                            .font(.body)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let url = item.link {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: url)
                }
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
