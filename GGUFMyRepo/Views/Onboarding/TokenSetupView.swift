import SwiftUI

struct TokenSetupView: View {
    @State private var token = ""

    var body: some View {
        Form {
            Section("Hugging Face Token") {
                SecureField("hf_...", text: $token)
                Button("Save Token") {}
            }
        }
        .navigationTitle("Setup")
    }
}
