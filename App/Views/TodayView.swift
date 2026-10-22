import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            // Re-evaluate at each rotation boundary so the screen matches the widgets.
            TimelineView(.periodic(from: Rotation.slotStart(for: .now), by: Double(model.rotationInterval.hours * 3600))) { context in
                ScrollView {
                    VStack(spacing: 16) {
                        if let quote = Rotation.currentQuote(at: context.date) {
                            QuoteCard(quote: quote)
                        }
                        if let word = Rotation.currentWord(at: context.date) {
                            WordCard(word: word)
                        }
                        Text("Changes \(model.rotationInterval.label.lowercased()). Next at \(nextChange(after: context.date), style: .time).")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 0) {
                            NavigationLink { QuoteListView() } label: { row("All quotes", "\(ContentLibrary.quotes.count)") }
                            Divider().padding(.leading)
                            NavigationLink { WordListView() } label: { row("All words", "\(ContentLibrary.words.count)") }
                        }
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding()
                }
            }
            .navigationTitle("Today")
        }
    }

    private func nextChange(after date: Date) -> Date {
        Rotation.slotStart(for: date).addingTimeInterval(Double(model.rotationInterval.hours * 3600))
    }

    private func row(_ title: String, _ detail: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(detail).foregroundStyle(.secondary)
            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary)
        }
        .padding()
        .contentShape(Rectangle())
    }
}

struct QuoteListView: View {
    @State private var search = ""

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filtered) { QuoteCard(quote: $0) }
            }
            .padding()
        }
        .searchable(text: $search)
        .navigationTitle("Quotes")
    }

    private var filtered: [Quote] {
        guard !search.isEmpty else { return ContentLibrary.quotes }
        return ContentLibrary.quotes.filter {
            $0.text.localizedCaseInsensitiveContains(search) || $0.author.localizedCaseInsensitiveContains(search)
        }
    }
}

struct WordListView: View {
    @State private var search = ""

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filtered) { WordCard(word: $0) }
            }
            .padding()
        }
        .searchable(text: $search)
        .navigationTitle("Words")
    }

    private var filtered: [Word] {
        let sorted = ContentLibrary.words.sorted { $0.word < $1.word }
        guard !search.isEmpty else { return sorted }
        return sorted.filter {
            $0.word.localizedCaseInsensitiveContains(search) || $0.definition.localizedCaseInsensitiveContains(search)
        }
    }
}
