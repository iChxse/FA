import Foundation

/// Bundled quotes and words, loaded once from JSON in the app or widget bundle.
enum ContentLibrary {
    static let quotes: [Quote] = load("quotes")
    static let words: [Word] = load("words")

    static func quote(id: String) -> Quote? { quotes.first { $0.id == id } }
    static func word(id: String) -> Word? { words.first { $0.id == id } }

    private static func load<T: Decodable>(_ name: String) -> [T] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([T].self, from: data) else {
            assertionFailure("Missing or invalid \(name).json")
            return []
        }
        return items
    }
}
