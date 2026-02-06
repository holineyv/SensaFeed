import Foundation

final class RSSParser: NSObject, XMLParserDelegate, Sendable {
    nonisolated func parse(data: Data) -> Feed? {
        let state = ParserState()
        let delegate = RSSParserDelegate(state: state)
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.parse()

        guard let title = state.channelTitle else { return nil }

        let items = state.items.map { raw in
            FeedItem(
                title: raw.title ?? "Untitled",
                link: raw.link.flatMap { URL(string: $0) },
                description: Self.stripHTML(raw.description ?? ""),
                pubDate: raw.pubDate.flatMap { Self.parseDate($0) },
                author: raw.author,
                imageURL: raw.imageURL.flatMap { URL(string: $0) }
            )
        }

        return Feed(
            title: title,
            url: URL(string: "about:blank")!,
            description: state.channelDescription ?? "",
            imageURL: state.channelImageURL.flatMap { URL(string: $0) },
            items: items
        )
    }

    private static func stripHTML(_ html: String) -> String {
        var text = html
        // Remove HTML tags
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        // Decode common HTML entities
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&#39;", with: "'")
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        // Collapse whitespace
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func parseDate(_ string: String) -> Date? {
        let formatters: [DateFormatter] = [
            {
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                return f
            }(),
            {
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                return f
            }(),
            {
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                return f
            }(),
            {
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                return f
            }(),
        ]
        for formatter in formatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }
}

// MARK: - Parser State (mutable, class-based for XMLParser delegate)

private final class ParserState {
    var channelTitle: String?
    var channelDescription: String?
    var channelImageURL: String?
    var items: [RawFeedItem] = []

    var currentElement: String = ""
    var currentText: String = ""
    var isInsideItem = false
    var isInsideImage = false
    var currentItem: RawFeedItem?
}

private struct RawFeedItem {
    var title: String?
    var link: String?
    var description: String?
    var pubDate: String?
    var author: String?
    var imageURL: String?
}

private final class RSSParserDelegate: NSObject, XMLParserDelegate {
    let state: ParserState

    init(state: ParserState) {
        self.state = state
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        state.currentElement = elementName
        state.currentText = ""

        if elementName == "item" || elementName == "entry" {
            state.isInsideItem = true
            state.currentItem = RawFeedItem()
        } else if elementName == "image" && !state.isInsideItem {
            state.isInsideImage = true
        } else if state.isInsideItem {
            let mediaURL = attributeDict["url"]
            let mediaType = attributeDict["type"]

            if elementName == "enclosure", let url = mediaURL,
               let type = mediaType, type.hasPrefix("image") {
                state.currentItem?.imageURL = url
            } else if elementName == "media:content", let url = mediaURL,
                      state.currentItem?.imageURL == nil {
                state.currentItem?.imageURL = url
            } else if elementName == "media:thumbnail", let url = mediaURL,
                      state.currentItem?.imageURL == nil {
                state.currentItem?.imageURL = url
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        state.currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        let text = state.currentText.trimmingCharacters(in: .whitespacesAndNewlines)

        if elementName == "item" || elementName == "entry" {
            if let item = state.currentItem {
                state.items.append(item)
            }
            state.isInsideItem = false
            state.currentItem = nil
        } else if elementName == "image" {
            state.isInsideImage = false
        } else if state.isInsideItem {
            switch elementName {
            case "title":
                state.currentItem?.title = text
            case "link":
                if state.currentItem?.link == nil || !text.isEmpty {
                    state.currentItem?.link = text
                }
            case "description", "summary", "content:encoded":
                if state.currentItem?.description == nil || elementName == "content:encoded" {
                    state.currentItem?.description = text
                }
            case "pubDate", "published", "updated":
                state.currentItem?.pubDate = text
            case "author", "dc:creator":
                state.currentItem?.author = text
            default:
                break
            }
        } else if state.isInsideImage {
            if elementName == "url" {
                state.channelImageURL = text
            }
        } else {
            switch elementName {
            case "title":
                if state.channelTitle == nil { state.channelTitle = text }
            case "description", "subtitle":
                if state.channelDescription == nil { state.channelDescription = text }
            default:
                break
            }
        }
    }
}
