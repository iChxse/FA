import Foundation

enum RotationInterval: Int, CaseIterable, Identifiable {
    case hourly = 1
    case every3Hours = 3
    case every6Hours = 6
    case daily = 24

    var id: Int { rawValue }
    var hours: Int { rawValue }

    var label: String {
        switch self {
        case .hourly: return "Every hour"
        case .every3Hours: return "Every 3 hours"
        case .every6Hours: return "Every 6 hours"
        case .daily: return "Once a day"
        }
    }
}

/// User preferences, stored in the App Group so the widget sees the same values.
enum Preferences {
    private static let intervalKey = "rotationIntervalHours"
    private static let favoritesOnlyKey = "favoritesOnly"
    private static let favoriteQuotesKey = "favoriteQuoteIDs"
    private static let favoriteWordsKey = "favoriteWordIDs"
    private static let wallpaperIndexKey = "wallpaperIndex"

    static var rotationInterval: RotationInterval {
        get { RotationInterval(rawValue: AppGroup.defaults.integer(forKey: intervalKey)) ?? .every3Hours }
        set { AppGroup.defaults.set(newValue.rawValue, forKey: intervalKey) }
    }

    /// When true, widgets only rotate through favorited items (if there are any).
    static var favoritesOnly: Bool {
        get { AppGroup.defaults.bool(forKey: favoritesOnlyKey) }
        set { AppGroup.defaults.set(newValue, forKey: favoritesOnlyKey) }
    }

    static var favoriteQuoteIDs: Set<String> {
        get { Set(AppGroup.defaults.stringArray(forKey: favoriteQuotesKey) ?? []) }
        set { AppGroup.defaults.set(Array(newValue), forKey: favoriteQuotesKey) }
    }

    static var favoriteWordIDs: Set<String> {
        get { Set(AppGroup.defaults.stringArray(forKey: favoriteWordsKey) ?? []) }
        set { AppGroup.defaults.set(Array(newValue), forKey: favoriteWordsKey) }
    }

    static var wallpaperIndex: Int {
        get { AppGroup.defaults.integer(forKey: wallpaperIndexKey) }
        set { AppGroup.defaults.set(newValue, forKey: wallpaperIndexKey) }
    }
}
