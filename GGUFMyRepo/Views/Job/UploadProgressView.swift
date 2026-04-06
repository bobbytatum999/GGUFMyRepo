import SwiftUI

struct UploadProgressView: View {
    let progress: Double

    var body: some View {
        VStack {
            GlassProgressRing(progress: progress)
            Label("Uploading", systemImage: "arrow.up.circle.fill")
        }
    }
}
