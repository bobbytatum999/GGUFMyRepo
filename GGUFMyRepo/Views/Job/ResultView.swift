import SwiftUI

struct ResultView: View {
    let inputBytes: Int64
    let outputBytes: Int64
    let repoURL: URL

    var body: some View {
        VStack(spacing: 16) {
            ConfettiView().frame(height: 120)
            Text("Success").font(.largeTitle.bold())
            Text("\(ByteCountFormatter.string(fromByteCount: inputBytes, countStyle: .file)) → \(ByteCountFormatter.string(fromByteCount: outputBytes, countStyle: .file))")
            Link("View on Hugging Face", destination: repoURL)
        }
        .padding()
    }
}
