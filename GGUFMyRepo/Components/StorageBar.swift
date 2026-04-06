import SwiftUI

struct StorageBar: View {
    let used: Double
    let needed: Double

    var body: some View {
        VStack(alignment: .leading) {
            ProgressView(value: min(1, used + needed))
            Text("Used: \(used.formatted(.percent)) · Needed: \(needed.formatted(.percent))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
