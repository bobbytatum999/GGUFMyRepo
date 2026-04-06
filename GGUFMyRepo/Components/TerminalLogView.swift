import SwiftUI

struct TerminalLogView: View {
    let lines: [String]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(lines, id: \.self) { line in
                    Text(line)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(line.contains("warning") ? .orange : .green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(8)
        .background(.black.opacity(0.95), in: RoundedRectangle(cornerRadius: 12))
    }
}
