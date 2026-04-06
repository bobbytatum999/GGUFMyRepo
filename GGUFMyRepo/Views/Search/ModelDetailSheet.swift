import SwiftUI

struct ModelDetailSheet: View {
    let modelId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(modelId).font(.title2.bold())
            Text("GGUF source files and metadata preview.")
        }
        .padding()
    }
}
