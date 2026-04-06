import Foundation

@MainActor
@Observable
final class AppSettingsStore {
    private let defaults = UserDefaults.standard
    private let key = "app_settings_v1"

    var settings: AppSettings {
        didSet { save() }
    }

    init() {
        if
            let data = defaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode(AppSettings.self, from: data)
        {
            settings = decoded
        } else {
            settings = AppSettings()
        }
    }

    func reset() {
        settings = AppSettings()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: key)
        }
    }
}
