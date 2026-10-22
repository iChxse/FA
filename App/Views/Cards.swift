import SwiftUI

struct QuoteCard: View {
    @EnvironmentObject private var model: AppModel
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Quote", systemImage: "quote.opening")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                FavoriteButton(isOn: model.isFavorite(quote)) { model.toggleFavorite(quote) }
            }
            Text(quote.text)
                .font(.system(.title3, design: .serif))
            Text("\u{2014} \(quote.author)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct WordCard: View {
    @EnvironmentObject private var model: AppModel
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Word", systemImage: "character.book.closed")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                FavoriteButton(isOn: model.isFavorite(word)) { model.toggleFavorite(word) }
            }
            HStack(alignment: .firstTextBaseline) {
                Text(word.word)
                    .font(.system(.largeTitle, design: .serif).weight(.semibold))
                Text(word.partOfSpeech)
                    .font(.subheadline.italic())
                    .foregroundStyle(.secondary)
            }
            Text(word.definition)
            Text(word.example)
                .font(.callout.italic())
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct FavoriteButton: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .foregroundStyle(isOn ? Color.pink : Color.secondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn ? "Remove from favorites" : "Add to favorites")
    }
}
