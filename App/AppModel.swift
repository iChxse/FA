import SwiftUI
import WidgetKit

/// App-wide state. Every change is written through to the shared `Preferences`
/// and the widgets are asked to reload so the lock screen picks it up.
@MainActor
final class AppModel: ObservableObject {
    @Published var favoriteQuoteIDs: Set<String> = Preferences.favoriteQuoteIDs {
        didSet { Preferences.favoriteQuoteIDs = favoriteQuoteIDs; reloadWidgets() }
    }
    @Published var favoriteWordIDs: Set<String> = Preferences.favoriteWordIDs {
        didSet { Preferences.favoriteWordIDs = favoriteWordIDs; reloadWidgets() }
    }
    @Published var rotationInterval: RotationInterval = Preferences.rotationInterval {
        didSet { Preferences.rotationInterval = rotationInterval; reloadWidgets() }
    }
    @Published var favoritesOnly: Bool = Preferences.favoritesOnly {
        didSet { Preferences.favoritesOnly = favoritesOnly; reloadWidgets() }
    }

    func isFavorite(_ quote: Quote) -> Bool { favoriteQuoteIDs.contains(quote.id) }
    func isFavorite(_ word: Word) -> Bool { favoriteWordIDs.contains(word.id) }

    func toggleFavorite(_ quote: Quote) {
        if favoriteQuoteIDs.contains(quote.id) { favoriteQuoteIDs.remove(quote.id) } else { favoriteQuoteIDs.insert(quote.id) }
    }

    func toggleFavorite(_ word: Word) {
        if favoriteWordIDs.contains(word.id) { favoriteWordIDs.remove(word.id) } else { favoriteWordIDs.insert(word.id) }
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
