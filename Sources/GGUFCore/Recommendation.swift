import Foundation

public enum ThermalLevel {
    case nominal, fair, serious, critical
}

public struct DeviceSpec {
    public let ramBytes: Int64
    public let availableRAMBytes: Int64
    public let thermal: ThermalLevel

    public init(ramBytes: Int64, availableRAMBytes: Int64, thermal: ThermalLevel) {
        self.ramBytes = ramBytes
        self.availableRAMBytes = availableRAMBytes
        self.thermal = thermal
    }
}

public struct Recommendation {
    public let suggestedType: QuantType
    public let isStorageBlocked: Bool
    public let willFitInRAM: Bool

    public init(suggestedType: QuantType, isStorageBlocked: Bool, willFitInRAM: Bool) {
        self.suggestedType = suggestedType
        self.isStorageBlocked = isStorageBlocked
        self.willFitInRAM = willFitInRAM
    }
}

public struct RecommendationEngine {
    public init() {}

    public func recommend(device: DeviceSpec, inputFileSize: Int64, parameterCount: Int64, availableStorage: Int64) -> Recommendation {
        let ramGB = Double(device.ramBytes) / 1_073_741_824
        let paramsB = Double(parameterCount) / 1_000_000_000

        var type: QuantType
        if ramGB >= 12 {
            if paramsB <= 7 { type = .q8_0 }
            else if paramsB <= 13 { type = .q5_k_m }
            else { type = .q4_k_m }
        } else if ramGB >= 8 {
            if paramsB <= 7 { type = .q5_k_m }
            else if paramsB <= 13 { type = .q4_k_m }
            else { type = .q3_k_m }
        } else {
            type = .q4_0
        }

        if device.thermal == .serious || device.thermal == .critical {
            type = downgrade(type)
        }

        let outputSize = Int64(Double(inputFileSize) * (type.bitsPerWeight / 16.0))
        let ramRequired = max(Int64(Double(inputFileSize) * 1.6), outputSize * 2)
        let fit = ramRequired < Int64(Double(device.availableRAMBytes) * 0.9)
        let storageBlocked = availableStorage < (inputFileSize * 2)

        return Recommendation(suggestedType: type, isStorageBlocked: storageBlocked, willFitInRAM: fit)
    }

    private func downgrade(_ type: QuantType) -> QuantType {
        switch type {
        case .q8_0: return .q6_k
        case .q6_k: return .q5_k_m
        case .q5_k_m: return .q4_k_m
        case .q4_k_m: return .q4_0
        case .q4_0: return .q3_k_m
        case .q3_k_m: return .q3_k_m
        }
    }
}
