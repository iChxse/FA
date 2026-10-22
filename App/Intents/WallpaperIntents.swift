import AppIntents
import UniformTypeIdentifiers

/// Returns the next wallpaper in the rotation as an image.
/// Pair it with Shortcuts' built-in "Set Wallpaper" action in a personal automation.
struct GetNextWallpaperIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Next Wallpaper"
    static var description = IntentDescription(
        "Returns the next wallpaper from FA. Follow it with Set Wallpaper to change your lock screen.",
        categoryName: "Wallpapers"
    )

    @Parameter(title: "Add Current Quote", default: false)
    var addQuote: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Get next wallpaper") {
            \.$addQuote
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
        guard let wallpaper = WallpaperLibrary.next() else {
            throw IntentError.noWallpapers
        }
        let quote = addQuote ? Rotation.currentQuote() : nil
        guard let data = WallpaperRenderer.render(wallpaper, quote: quote) else {
            throw IntentError.renderFailed
        }
        let file = IntentFile(data: data, filename: "fa-wallpaper.jpg", type: .jpeg)
        return .result(value: file)
    }
}

/// Handy for Shortcuts that want the text itself (e.g. to show a notification).
struct GetCurrentQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current Quote"
    static var description = IntentDescription("Returns the quote currently shown in FA's widgets.")

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let quote = Rotation.currentQuote() else { throw IntentError.noContent }
        return .result(value: "\u{201C}\(quote.text)\u{201D} \u{2014} \(quote.author)")
    }
}

struct GetCurrentWordIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current Word"
    static var description = IntentDescription("Returns the word and definition currently shown in FA's widgets.")

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let word = Rotation.currentWord() else { throw IntentError.noContent }
        return .result(value: "\(word.word) (\(word.partOfSpeech)): \(word.definition)")
    }
}

enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case noWallpapers
    case renderFailed
    case noContent

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noWallpapers: return "There are no wallpapers in FA yet."
        case .renderFailed: return "FA couldn't prepare the wallpaper."
        case .noContent: return "FA has nothing to show right now."
        }
    }
}

struct FAShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetNextWallpaperIntent(),
            phrases: ["Get next wallpaper from \(.applicationName)", "Next \(.applicationName) wallpaper"],
            shortTitle: "Next Wallpaper",
            systemImageName: "photo.on.rectangle"
        )
        AppShortcut(
            intent: GetCurrentQuoteIntent(),
            phrases: ["Get quote from \(.applicationName)"],
            shortTitle: "Current Quote",
            systemImageName: "quote.opening"
        )
        AppShortcut(
            intent: GetCurrentWordIntent(),
            phrases: ["Get word from \(.applicationName)"],
            shortTitle: "Current Word",
            systemImageName: "character.book.closed"
        )
    }
}
