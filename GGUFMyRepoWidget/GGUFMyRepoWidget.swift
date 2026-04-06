import WidgetKit
import SwiftUI

struct GGUFJobEntry: TimelineEntry {
    let date: Date
    let modelName: String
    let progress: Double
    let phase: String
}

struct GGUFWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> GGUFJobEntry {
        GGUFJobEntry(date: Date(), modelName: "Llama-3-8B", progress: 0.42, phase: "Quantizing")
    }

    func getSnapshot(in context: Context, completion: @escaping (GGUFJobEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GGUFJobEntry>) -> Void) {
        let entry = loadEntryFromDefaults() ?? placeholder(in: context)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
        completion(timeline)
    }

    private func loadEntryFromDefaults() -> GGUFJobEntry? {
        let defaults = UserDefaults(suiteName: "group.com.ggufmyrepo.shared")
        guard
            let modelName = defaults?.string(forKey: "widget_model_name"),
            let phase = defaults?.string(forKey: "widget_phase")
        else { return nil }

        let progress = defaults?.double(forKey: "widget_progress") ?? 0
        return GGUFJobEntry(date: Date(), modelName: modelName, progress: progress, phase: phase)
    }
}

struct GGUFWidgetView: View {
    var entry: GGUFWidgetProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GGUFMyRepo")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(entry.modelName)
                .font(.headline)
                .lineLimit(1)
            ProgressView(value: entry.progress)
            Text("\(entry.phase) · \(Int(entry.progress * 100))%")
                .font(.caption2)
        }
        .padding(12)
    }
}

struct GGUFMyRepoWidget: Widget {
    let kind: String = "GGUFMyRepoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GGUFWidgetProvider()) { entry in
            GGUFWidgetView(entry: entry)
        }
        .configurationDisplayName("Active Quant Job")
        .description("Track GGUF job progress on your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    GGUFMyRepoWidget()
} timeline: {
    GGUFJobEntry(date: .now, modelName: "Llama-3-8B", progress: 0.8, phase: "Uploading")
}
