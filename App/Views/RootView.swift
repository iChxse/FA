import SwiftUI

enum AppTab: Hashable {
    case today, favorites, wallpapers, setup
}

struct RootView: View {
    @State private var tab: AppTab = .today

    var body: some View {
        TabView(selection: $tab) {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }
                .tag(AppTab.today)
            FavoritesView()
                .tabItem { Label("Favorites", systemImage: "heart") }
                .tag(AppTab.favorites)
            WallpapersView()
                .tabItem { Label("Wallpapers", systemImage: "photo.on.rectangle") }
                .tag(AppTab.wallpapers)
            SetupView()
                .tabItem { Label("Setup", systemImage: "gearshape") }
                .tag(AppTab.setup)
        }
        // Widgets link to fa://quote/<id> and fa://word/<id>; both live on Today.
        .onOpenURL { _ in tab = .today }
    }
}
