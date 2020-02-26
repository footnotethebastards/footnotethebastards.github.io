import Foundation
import Publish
import Plot
import FeedKit

// This type acts as the configuration for your website.
struct Footnote: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case episodes
        case about
    }

    struct ItemMetadata: WebsiteItemMetadata {
        let title: String
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://footnotethebastards.github.io")!
    var name = "Footnote the Bastards"
    var description = "Every footnote you ever wanted to read in more depth yourself about the worst people in all of history."
    var language: Language { .english }
    var imagePath: Path? { nil }
}

extension String {
    var urlPathString: String {
        self.components(separatedBy: CharacterSet.urlPathAllowed.inverted).joined(separator: "-")
    }
    
    var polishContent: String {
        let prefix = "<![CDATA["
        guard self.hasPrefix(prefix) else {
            return self
        }
        let string = self.dropFirst(prefix.count)
        let suffix = "]]>"
        guard string.hasSuffix(suffix) else {
            return String(string)
        }
        return String(string.dropLast(suffix.count))
    }
}

let feedUrl = URL(string: "https://feeds.megaphone.fm/behindthebastards")!

// This will generate your website using the built-in Foundation theme:
try Footnote().publish(
    withTheme: .foundation,
    additionalSteps: [
        .step(named: "Fetch Feed", body: { context in
            let feed = FeedParser(URL: feedUrl).parse()
            if case Result.failure(_) = feed {
                fatalError("Failed to parse feed \(feedUrl)")
            }
            guard let rss = try? feed.get().rssFeed else {
                fatalError("No atom feed")
            }
            rss.items?.forEach { entry in
                context.mutateAllSections { section in
                    guard let title = entry.title?.trimmingCharacters(in: .whitespacesAndNewlines),
                        let content = entry.content?.contentEncoded,
                        let date = entry.pubDate else {
                            return
                    }
                    switch section.id {
                    case .episodes:
                        section.addItem(
                            at: Path(title.urlPathString),
                            withMetadata: Footnote.ItemMetadata(title: title)) { episode in
                                episode.content.body = Content.Body(
                                    html: "<h3>\(title)</h3><p>\(content.polishContent)")
                                episode.title = title
                                episode.date = date
                        }
                    default:
                        break
                    }
                }
            }
        })
    ]
)
