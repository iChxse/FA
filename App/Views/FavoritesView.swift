import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            Group {
                if quotes.isEmpty && words.isEmpty {
                    ContentUnavailableView(
                        "No favorites yet",
                        systemImage: "heart",
                        description: Text("Tap the heart on a quote or word to save it here.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            Toggle("Only show favorites in widgets", isOn: $model.favoritesOnly)
                                .padding()
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            ForEach(quotes) { QuoteCard(quote: $0) }
                            ForEach(words) { WordCard(word: $0) }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }

    private var quotes: [Quote] { ContentLibrary.quotes.filter { model.isFavorite($0) } }
    private var words: [Word] { ContentLibrary.words.filter { model.isFavorite($0) } }
}
