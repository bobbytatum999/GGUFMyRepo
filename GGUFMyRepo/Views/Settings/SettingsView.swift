import SwiftUI
import Metal

struct SettingsView: View {
    let appState: AppState
    @State private var token = ""

    var body: some View {
        Form {
            Section("Account") {
                SecureField("Hugging Face token", text: $token)
                Button("Logout") {}
            }
            Section("Hardware") {
                let info = DeviceInfo.current()
                Text(info.profile.deviceName)
                Text(info.profile.chipName)
                if let metal = MTLCreateSystemDefaultDevice() {
                    Text(metal.name)
                }
            }
            Section("Appearance") {
                ColorPicker("Accent", selection: $appState.accentColor)
            }
        }
        .navigationTitle("Settings")
    }
}
