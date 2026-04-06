import Foundation

struct WidgetSyncService {
    private let defaults = UserDefaults(suiteName: "group.com.ggufmyrepo.shared")

    func update(modelName: String, phase: String, progress: Double) {
        defaults?.set(modelName, forKey: "widget_model_name")
        defaults?.set(phase, forKey: "widget_phase")
        defaults?.set(progress, forKey: "widget_progress")
    }

    func clear() {
        defaults?.removeObject(forKey: "widget_model_name")
        defaults?.removeObject(forKey: "widget_phase")
        defaults?.removeObject(forKey: "widget_progress")
    }
}
