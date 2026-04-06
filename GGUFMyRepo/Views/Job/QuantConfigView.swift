import SwiftUI

struct QuantConfigView: View {
    @State private var selected: QuantType = .q5_k_m
    @State private var threads = 4

    var body: some View {
        Form {
            Picker("Quant Type", selection: $selected) {
                ForEach(QuantType.allCases) { Text($0.rawValue).tag($0) }
            }
            Stepper("Threads: \(threads)", value: $threads, in: 1...16)
            Toggle("imatrix (coming in v2)", isOn: .constant(false))
                .disabled(true)
        }
        .navigationTitle("Configure")
    }
}
