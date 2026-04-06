import SwiftUI

@main
struct GGUFMyRepoApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView(appState: appState)
        }
    }
}

@Observable
final class AppState {
    var jobs: [QuantJob] = []
    var hasCompletedOnboarding = false
    var accentColor: Color = .orange
}
