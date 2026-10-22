import Foundation

/// Picks which quote or word to show for a given moment.
/// The choice is deterministic per time slot, so the app, the widget and the
/// Shortcuts action all agree on what is "current" without talking to each other.
enum Rotation {
    static func currentQuote(at date: Date = .now) -> Quote? {
        pick(from: quotePool, at: date, salt: 0x51)
    }

    static func currentWord(at date: Date = .now) -> Word? {
        pick(from: wordPool, at: date, salt: 0x57)
    }

    /// Start of the rotation slot containing `date`.
    static func slotStart(for date: Date) -> Date {
        let seconds = Double(Preferences.rotationInterval.hours * 3600)
        let slot = (date.timeIntervalSince1970 / seconds).rounded(.down)
        return Date(timeIntervalSince1970: slot * seconds)
    }

    /// The next `count` slot start times, beginning with the current slot.
    static func upcomingSlots(from date: Date = .now, count: Int) -> [Date] {
        let start = slotStart(for: date)
        let step = TimeInterval(Preferences.rotationInterval.hours * 3600)
        return (0..<count).map { start.addingTimeInterval(Double($0) * step) }
    }

    private static var quotePool: [Quote] {
        let favorites = Preferences.favoriteQuoteIDs
        let all = ContentLibrary.quotes
        guard Preferences.favoritesOnly, !favorites.isEmpty else { return all }
        return all.filter { favorites.contains($0.id) }
    }

    private static var wordPool: [Word] {
        let favorites = Preferences.favoriteWordIDs
        let all = ContentLibrary.words
        guard Preferences.favoritesOnly, !favorites.isEmpty else { return all }
        return all.filter { favorites.contains($0.id) }
    }

    private static func pick<T>(from items: [T], at date: Date, salt: UInt64) -> T? {
        guard !items.isEmpty else { return nil }
        let hours = UInt64(Preferences.rotationInterval.hours)
        let slot = UInt64(max(0, date.timeIntervalSince1970)) / (hours * 3600)
        // Walk through a shuffled order of the whole list before repeating anything.
        let cycle = slot / UInt64(items.count)
        let position = Int(slot % UInt64(items.count))
        var rng = SplitMix64(seed: cycle &* 0x9E37_79B9 ^ salt)
        let order = Array(items.indices).shuffled(using: &rng)
        return items[order[position]]
    }
}

/// Small seeded generator so shuffles are stable across processes.
struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
