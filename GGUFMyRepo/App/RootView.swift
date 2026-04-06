import SwiftUI

struct RootView: View {
    let appState: AppState

    var body: some View {
        TabView {
            NavigationStack { ModelSearchView(appState: appState) }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            NavigationStack { JobHistoryView(appState: appState) }
                .tabItem { Label("Jobs", systemImage: "waveform") }

            NavigationStack { SettingsView(appState: appState) }
                .tabItem { Label("Settings", systemImage: "gearshape.2.fill") }
        }
        .tint(appState.accentColor)
    }
}
