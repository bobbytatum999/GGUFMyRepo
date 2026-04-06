import SwiftUI

struct ThermalStateBadge: View {
    let state: ProcessInfo.ThermalState

    private var color: Color {
        switch state {
        case .nominal: return .green
        case .fair: return .yellow
        case .serious: return .orange
        case .critical: return .red
        @unknown default: return .gray
        }
    }

    var body: some View {
        Label(String(describing: state), systemImage: "thermometer.medium")
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.2), in: Capsule())
            .overlay(Capsule().stroke(color, lineWidth: 1.5))
    }
}
