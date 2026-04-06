import SwiftUI

struct DownloadProgressView: View {
    let progress: Double

    var body: some View {
        VStack {
            GlassProgressRing(progress: progress)
            Label("Downloading", systemImage: "arrow.down.circle.fill")
        }
    }
}
