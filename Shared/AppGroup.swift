import Foundation

/// Storage shared between the app and the widget extension.
/// If the App Group isn't provisioned (e.g. a free signing team), this quietly falls back
/// to per-process storage: everything still works, but favorites won't reach the widget.
enum AppGroup {
    static let identifier = "group.com.ichxse.fa"

    static let defaults: UserDefaults = UserDefaults(suiteName: identifier) ?? .standard

    static var containerURL: URL {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) {
            return url
        }
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }
}
