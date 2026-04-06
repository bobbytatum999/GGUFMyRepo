import Foundation

struct DeviceProfile: Codable, Hashable {
    enum Tier: String, Codable { case pro, standard, legacy, fallback }

    let machine: String
    let deviceName: String
    let chipName: String
    let ramBytes: Int64
    let tier: Tier
}
