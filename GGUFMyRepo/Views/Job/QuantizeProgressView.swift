import SwiftUI

struct QuantizeProgressView: View {
    let progress: Double
    let tensor: String
    let thermal: ProcessInfo.ThermalState
    let eta: TimeInterval
    let throughputBytesPerSecond: Double

    private var throughputText: String {
        let measurement = Measurement(value: throughputBytesPerSecond, unit: UnitInformationStorage.bytes)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .short
        return formatter.string(from: measurement) + "/s"
    }

    private var etaText: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: eta) ?? "—"
    }

    var body: some View {
        VStack(spacing: 12) {
            GlassProgressRing(progress: progress)
            ThermalStateBadge(state: thermal)
            HStack {
                Label("ETA \(etaText)", systemImage: "clock")
                Spacer()
                Label(throughputText, systemImage: "speedometer")
            }
            .font(.caption)
            Text(tensor).font(.system(.caption, design: .monospaced))
        }
        .padding()
    }
}
