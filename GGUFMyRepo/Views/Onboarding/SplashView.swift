import SwiftUI

struct SplashView: View {
    let info: DeviceInfo

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cpu")
                .font(.system(size: 44))
            Text("Running on \(info.profile.chipName) · \(info.profile.ramBytes / 1_073_741_824) GB RAM")
                .multilineTextAlignment(.center)
                .font(.headline)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
