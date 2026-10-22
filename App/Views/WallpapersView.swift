import PhotosUI
import SwiftUI

struct WallpapersView: View {
    @State private var wallpapers: [Wallpaper] = WallpaperLibrary.all()
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var preview: Wallpaper?

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("The Shortcuts action cycles through these in order. Add your own photos with the + button.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(wallpapers) { wallpaper in
                        Button { preview = wallpaper } label: {
                            WallpaperThumbnail(wallpaper: wallpaper)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            if !wallpaper.isBundled {
                                Button("Remove", systemImage: "trash", role: .destructive) {
                                    WallpaperLibrary.delete(wallpaper)
                                    wallpapers = WallpaperLibrary.all()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Wallpapers")
            .toolbar {
                PhotosPicker(selection: $pickerItems, matching: .images) {
                    Image(systemName: "plus")
                }
            }
            .onChange(of: pickerItems) { _, items in
                Task { await importPhotos(items) }
            }
            .sheet(item: $preview) { WallpaperPreview(wallpaper: $0) }
        }
    }

    private func importPhotos(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                try? WallpaperLibrary.importImage(data)
            }
        }
        pickerItems = []
        wallpapers = WallpaperLibrary.all()
    }
}

private struct WallpaperThumbnail: View {
    let wallpaper: Wallpaper

    var body: some View {
        Color.clear
            .aspectRatio(9.0 / 19.5, contentMode: .fit)
            .overlay {
                if let image = UIImage(contentsOfFile: wallpaper.url.path)?.preparingThumbnail(of: CGSize(width: 240, height: 520)) {
                    Image(uiImage: image).resizable().scaledToFill()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                if !wallpaper.isBundled {
                    Image(systemName: "person.crop.square")
                        .font(.caption)
                        .padding(6)
                        .foregroundStyle(.white)
                }
            }
    }
}

/// Full-screen preview, with an option to see the quote overlay the Shortcuts action can add.
private struct WallpaperPreview: View {
    let wallpaper: Wallpaper
    @State private var showQuote = false
    @State private var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            if let image {
                Image(uiImage: image).resizable().scaledToFill().ignoresSafeArea()
            }
            HStack {
                Toggle("Add current quote", isOn: $showQuote)
                    .toggleStyle(.button)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial, in: Capsule())
            .padding()
        }
        .task(id: showQuote) {
            let data = WallpaperRenderer.render(wallpaper, quote: showQuote ? Rotation.currentQuote() : nil)
            image = data.flatMap(UIImage.init(data:))
        }
    }
}
