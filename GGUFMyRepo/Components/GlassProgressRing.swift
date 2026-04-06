import SwiftUI

struct GlassProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle().stroke(.ultraThinMaterial, lineWidth: 14)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.orange.gradient, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.headline.monospacedDigit())
        }
        .padding()
    }
}
