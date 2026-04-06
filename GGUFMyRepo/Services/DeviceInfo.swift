import Foundation
import UIKit
import Darwin

@_silgen_name("gguf_available_ram_bytes")
private func gguf_available_ram_bytes() -> Int64

struct DeviceInfo {
    let machine: String
    let totalRAMBytes: Int64
    let logicalCPUs: Int
    let physicalCPUs: Int
    let availableRAMBytes: Int64
    let thermalState: ProcessInfo.ThermalState
    let deviceName: String
    let systemVersion: String
    let profile: DeviceProfile

    static func current() -> DeviceInfo {
        let machine = sysctlString("hw.machine") ?? "Unknown"
        let memsize = Int64(sysctlUInt64("hw.memsize") ?? 0)
        let ncpu = Int(sysctlInt("hw.ncpu") ?? 0)
        let pCpu = Int(sysctlInt("hw.physicalcpu") ?? 0)
        let profile = DeviceCatalog.profile(for: machine, detectedRam: memsize)

        return DeviceInfo(
            machine: machine,
            totalRAMBytes: memsize,
            logicalCPUs: ncpu,
            physicalCPUs: pCpu,
            availableRAMBytes: DeviceMemoryBridge.availableRAM(),
            thermalState: ProcessInfo.processInfo.thermalState,
            deviceName: UIDevice.current.name,
            systemVersion: UIDevice.current.systemVersion,
            profile: profile
        )
    }
}

enum DeviceCatalog {
    private static let map: [String: DeviceProfile] = [
        "iPhone18,1": .init(machine: "iPhone18,1", deviceName: "iPhone 17e", chipName: "A19", ramBytes: 8 * 1024 * 1024 * 1024, tier: .standard),
        "iPhone18,2": .init(machine: "iPhone18,2", deviceName: "iPhone 17", chipName: "A19", ramBytes: 8 * 1024 * 1024 * 1024, tier: .standard),
        "iPhone18,3": .init(machine: "iPhone18,3", deviceName: "iPhone Air", chipName: "A19 Pro", ramBytes: 12 * 1024 * 1024 * 1024, tier: .pro),
        "iPhone18,4": .init(machine: "iPhone18,4", deviceName: "iPhone 17 Pro", chipName: "A19 Pro", ramBytes: 12 * 1024 * 1024 * 1024, tier: .pro),
        "iPhone18,5": .init(machine: "iPhone18,5", deviceName: "iPhone 17 Pro Max", chipName: "A19 Pro", ramBytes: 12 * 1024 * 1024 * 1024, tier: .pro),
        "iPhone17,1": .init(machine: "iPhone17,1", deviceName: "iPhone 16 Pro", chipName: "A18 Pro", ramBytes: 8 * 1024 * 1024 * 1024, tier: .pro),
        "iPhone17,2": .init(machine: "iPhone17,2", deviceName: "iPhone 16 Pro Max", chipName: "A18 Pro", ramBytes: 8 * 1024 * 1024 * 1024, tier: .pro),
        "iPhone17,3": .init(machine: "iPhone17,3", deviceName: "iPhone 16", chipName: "A18", ramBytes: 8 * 1024 * 1024 * 1024, tier: .standard),
        "iPhone17,4": .init(machine: "iPhone17,4", deviceName: "iPhone 16 Plus", chipName: "A18", ramBytes: 8 * 1024 * 1024 * 1024, tier: .standard),
        "iPhone16,1": .init(machine: "iPhone16,1", deviceName: "iPhone 15 Pro", chipName: "A17 Pro", ramBytes: 8 * 1024 * 1024 * 1024, tier: .pro),
        "iPhone16,2": .init(machine: "iPhone16,2", deviceName: "iPhone 15 Pro Max", chipName: "A17 Pro", ramBytes: 8 * 1024 * 1024 * 1024, tier: .pro),
        "iPhone15,4": .init(machine: "iPhone15,4", deviceName: "iPhone 15", chipName: "A16", ramBytes: 6 * 1024 * 1024 * 1024, tier: .standard),
        "iPhone15,5": .init(machine: "iPhone15,5", deviceName: "iPhone 15 Plus", chipName: "A16", ramBytes: 6 * 1024 * 1024 * 1024, tier: .standard),
        "iPhone14,2": .init(machine: "iPhone14,2", deviceName: "iPhone 13 Pro", chipName: "A15", ramBytes: 6 * 1024 * 1024 * 1024, tier: .legacy)
    ]

    static func profile(for machine: String, detectedRam: Int64) -> DeviceProfile {
        map[machine] ?? .init(machine: machine, deviceName: "Unknown iPhone", chipName: "—", ramBytes: detectedRam, tier: .fallback)
    }
}

private func sysctlString(_ key: String) -> String? {
    var size: size_t = 0
    guard sysctlbyname(key, nil, &size, nil, 0) == 0 else { return nil }
    var data = [CChar](repeating: 0, count: size)
    guard sysctlbyname(key, &data, &size, nil, 0) == 0 else { return nil }
    return String(cString: data)
}

private func sysctlUInt64(_ key: String) -> UInt64? {
    var value: UInt64 = 0
    var size = MemoryLayout<UInt64>.size
    return sysctlbyname(key, &value, &size, nil, 0) == 0 ? value : nil
}

private func sysctlInt(_ key: String) -> Int32? {
    var value: Int32 = 0
    var size = MemoryLayout<Int32>.size
    return sysctlbyname(key, &value, &size, nil, 0) == 0 ? value : nil
}

enum DeviceMemoryBridge {
    static func availableRAM() -> Int64 {
        let bytes = gguf_available_ram_bytes()
        return bytes > 0 ? bytes : Int64(ProcessInfo.processInfo.physicalMemory / 4)
    }
}
