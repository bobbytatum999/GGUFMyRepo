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
                Text("\(device.profile.ramBytes / 1_073_741_824) GB")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: Capsule())
            }

            HStack {
                Text(recommendation.suggestedType.rawValue)
                    .font(.headline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.yellow.gradient, in: Capsule())
                Spacer()
                Text(String(repeating: "★", count: recommendation.suggestedType.qualityStars) + String(repeating: "☆", count: max(0, 5 - recommendation.suggestedType.qualityStars)))
                    .font(.caption)
            }

            Text("Est. output: \(ByteCountFormatter.string(fromByteCount: recommendation.estimatedOutputSize, countStyle: .file))")
            Text("Est. RAM needed: \(ByteCountFormatter.string(fromByteCount: recommendation.estimatedRAMRequired, countStyle: .memory))")
                .font(.caption)
                .foregroundStyle(.secondary)

            if recommendation.isStorageBlocked {
                Label("Not enough storage (need at least 2× input size)", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Button(expanded ? "Hide Why" : "Why this recommendation?") { expanded.toggle() }
            if expanded {
                VStack(alignment: .leading, spacing: 6) {
                    Text(recommendation.reasoning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(recommendation.warnings, id: \.self) { warning in
                        Label(warning, systemImage: "thermometer.medium")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
