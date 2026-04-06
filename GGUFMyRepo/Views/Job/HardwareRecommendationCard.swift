import SwiftUI

struct HardwareRecommendationCard: View {
    let recommendation: QuantRecommendation
    let device: DeviceInfo
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(device.profile.chipName, systemImage: "memorychip")
                Spacer()
                Text(recommendation.suggestedType.rawValue)
                    .font(.headline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.yellow.gradient, in: Capsule())
            }
            Text("Est. output: \(ByteCountFormatter.string(fromByteCount: recommendation.estimatedOutputSize, countStyle: .file))")
            Button(expanded ? "Hide Why" : "Why this recommendation?") { expanded.toggle() }
            if expanded { Text(recommendation.reasoning).font(.caption).foregroundStyle(.secondary) }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
