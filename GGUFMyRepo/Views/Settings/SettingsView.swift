import SwiftUI
import Metal

struct SettingsView: View {
    @Bindable var appState: AppState
    @State private var token = ""
    @State private var settingsStore = AppSettingsStore()

    var body: some View {
        Form {
            accountSection
            hardwareSection
            quantSection
            downloadSection
            uploadSection
            appearanceSection
            notificationsSection
            Section {
                Button("Reset all settings", role: .destructive) {
                    settingsStore.reset()
                }
            }
        }
        .navigationTitle("Settings")
    }

    private var accountSection: some View {
        Section("Account") {
            SecureField("Hugging Face token", text: $token)
            Button("Logout") {}
        }
    }

    private var hardwareSection: some View {
        Section("Hardware") {
            let info = DeviceInfo.current()
            Text(info.profile.deviceName)
            Text(info.profile.chipName)
            if let metal = MTLCreateSystemDefaultDevice() {
                Text(metal.name)
            }
        }
    }

    private var quantSection: some View {
        Section("Quantization") {
            Stepper("Default Threads: \(settingsStore.settings.defaultThreads)", value: $settingsStore.settings.defaultThreads, in: 1...16)
            Toggle("Always show recommendation card", isOn: $settingsStore.settings.autoShowRecommendationCard)
            Toggle("Pause on critical thermal", isOn: $settingsStore.settings.pauseOnThermalCritical)
            Toggle("Warn on serious thermal", isOn: $settingsStore.settings.warnOnThermalSerious)
            Toggle("Auto-delete source after success", isOn: $settingsStore.settings.autoDeleteSourceAfterSuccess)
            Toggle("Auto-delete output after upload", isOn: $settingsStore.settings.autoDeleteOutputAfterUpload)
        }
    }

    private var downloadSection: some View {
        Section("Download") {
            Stepper("Max concurrent downloads: \(settingsStore.settings.maxConcurrentDownloads)", value: $settingsStore.settings.maxConcurrentDownloads, in: 1...3)
            Toggle("Auto-resume on launch", isOn: $settingsStore.settings.autoResumeDownloadsOnLaunch)
            TextField("Download subdirectory", text: $settingsStore.settings.preferredDownloadSubdirectory)
        }
    }

    private var uploadSection: some View {
        Section("Upload") {
            Toggle("Default private visibility", isOn: $settingsStore.settings.defaultOutputVisibilityPrivate)
            Picker("Chunk size", selection: $settingsStore.settings.uploadChunkSize) {
                ForEach(UploadChunkSize.allCases, id: \.self) { size in
                    Text("\(size.rawValue) MB").tag(size)
                }
            }
            Picker("Network", selection: $settingsStore.settings.uploadPolicy) {
                ForEach(NetworkPolicy.allCases, id: \.self) { policy in
                    Text(policy == .wifiOnly ? "Wi-Fi only" : "Any network").tag(policy)
                }
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            ColorPicker("Accent", selection: $appState.accentColor)
            Toggle("Show tensor names", isOn: $settingsStore.settings.showTensorNames)
            Toggle("Compact mode", isOn: $settingsStore.settings.compactMode)
            Picker("Log verbosity", selection: $settingsStore.settings.logVerbosity) {
                ForEach(LogVerbosity.allCases, id: \.self) { verbosity in
                    Text(verbosity.rawValue.capitalized).tag(verbosity)
                }
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Notify on download completion", isOn: $settingsStore.settings.notifyOnDownloadCompletion)
            Toggle("Notify on quant completion", isOn: $settingsStore.settings.notifyOnQuantCompletion)
            Toggle("Notify on upload completion", isOn: $settingsStore.settings.notifyOnUploadCompletion)
            Toggle("Notify on failures", isOn: $settingsStore.settings.notifyOnFailure)
        }
    }
}
