import WidgetKit

struct RotationEntry: TimelineEntry {
    let date: Date
    let quote: Quote?
    let word: Word?

    static let sample = RotationEntry(
        date: .now,
        quote: Quote(id: "sample", text: "The best way out is always through.", author: "Robert Frost"),
        word: Word(id: "sample", word: "sonder", partOfSpeech: "noun",
                   definition: "The realization that each passerby has a life as vivid and complex as your own.",
                   example: "")
    )
}

/// Pre-computes a timeline of upcoming rotation slots so the widget changes on
/// schedule without the app running.
struct RotationProvider: TimelineProvider {
    func placeholder(in context: Context) -> RotationEntry { .sample }

    func getSnapshot(in context: Context, completion: @escaping (RotationEntry) -> Void) {
        completion(context.isPreview ? .sample : entry(at: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RotationEntry>) -> Void) {
        // At least a day's worth of entries, and never fewer than a week of slots.
        let count = max(7, 24 / Preferences.rotationInterval.hours)
        let entries = Rotation.upcomingSlots(count: count).map(entry(at:))
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func entry(at date: Date) -> RotationEntry {
        RotationEntry(date: date, quote: Rotation.currentQuote(at: date), word: Rotation.currentWord(at: date))
    }
}
