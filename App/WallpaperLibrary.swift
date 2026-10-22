import UIKit

struct Wallpaper: Identifiable, Hashable {
    let url: URL
    let isBundled: Bool

    var id: String { url.lastPathComponent }
    var name: String { url.deletingPathExtension().lastPathComponent.capitalized }
}

/// Bundled wallpapers plus any photos the user imports.
/// Imported photos live in the App Group container so they survive app updates.
enum WallpaperLibrary {
    static var userFolder: URL {
        let url = AppGroup.containerURL.appendingPathComponent("Wallpapers", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func all() -> [Wallpaper] {
        let bundled = (Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: "Wallpapers") ?? [])
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { Wallpaper(url: $0, isBundled: true) }
        let imported = ((try? FileManager.default.contentsOfDirectory(at: userFolder, includingPropertiesForKeys: [.creationDateKey])) ?? [])
            .filter { $0.pathExtension.lowercased() == "jpg" }
            .sorted { creationDate($0) < creationDate($1) }
            .map { Wallpaper(url: $0, isBundled: false) }
        return imported + bundled
    }

    @discardableResult
    static func importImage(_ data: Data) throws -> Wallpaper {
        guard let image = UIImage(data: data), let jpeg = image.jpegData(compressionQuality: 0.9) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let url = userFolder.appendingPathComponent("\(UUID().uuidString).jpg")
        try jpeg.write(to: url, options: .atomic)
        return Wallpaper(url: url, isBundled: false)
    }

    static func delete(_ wallpaper: Wallpaper) {
        guard !wallpaper.isBundled else { return }
        try? FileManager.default.removeItem(at: wallpaper.url)
    }

    /// Advances the shared cursor and returns the next wallpaper in the rotation.
    static func next() -> Wallpaper? {
        let items = all()
        guard !items.isEmpty else { return nil }
        let index = Preferences.wallpaperIndex % items.count
        Preferences.wallpaperIndex = index + 1
        return items[index]
    }

    private static func creationDate(_ url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
    }
}
