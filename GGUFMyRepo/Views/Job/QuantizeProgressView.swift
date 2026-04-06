import SwiftUI

struct QuantizeProgressView: View {
    let progress: Double
    let tensor: String
    let thermal: ProcessInfo.ThermalState

    var body: some View {
        VStack(spacing: 12) {
            GlassProgressRing(progress: progress)
            ThermalStateBadge(state: thermal)
            Text(tensor).font(.system(.caption, design: .monospaced))
        }
    }
}
