import Foundation

enum RecommendationConfidence: String, Codable { case high, medium, low }

struct QuantRecommendation {
    let suggestedType: QuantType
    let alternativeTypes: [QuantType]
    let reasoning: String
    let estimatedOutputSize: Int64
    let estimatedRAMRequired: Int64
    let estimatedDuration: TimeInterval
    let willFitInRAM: Bool
    let confidenceLevel: RecommendationConfidence
    let warnings: [String]
    let isStorageBlocked: Bool
}

struct QuantRecommendationEngine {
    func recommend(
        device: DeviceInfo,
        inputFileSize: Int64,
        parameterCount: Int64?,
        availableStorage: Int64
    ) -> QuantRecommendation {
        let params = parameterCount ?? Int64(Double(inputFileSize) / 2.0)
        let ramGB = Double(device.totalRAMBytes) / 1_073_741_824
        var quant = baseQuant(ramGB: ramGB, params: params)
        var warnings: [String] = []

        if device.thermalState == .serious || device.thermalState == .critical {
            quant = downgraded(quant)
            warnings.append("Thermal state is elevated; recommendation was downgraded one tier.")
        }

        if ramGB < 8 {
            warnings.append("6GB-class devices may need extra free space and more time to complete quantization.")
        }

        let outputSize = Int64(Double(inputFileSize) * (quant.bitsPerWeight / 16.0))
        let ramReq = max(Int64(Double(inputFileSize) * 1.6), outputSize * 2)
        let fit = ramReq < Int64(Double(device.availableRAMBytes) * 0.9)
        let eta = max(60, Double(inputFileSize) / 85_000_000)
        let storageBlocked = availableStorage < (inputFileSize * 2)

        if storageBlocked {
            warnings.append("Available storage is below 2× input size; download/quantization should be blocked until space is freed.")
        }

        return QuantRecommendation(
            suggestedType: quant,
            alternativeTypes: alternatives(for: quant),
            reasoning: explanation(ramGB: ramGB, params: params, quant: quant),
            estimatedOutputSize: outputSize,
            estimatedRAMRequired: ramReq,
            estimatedDuration: eta,
            willFitInRAM: fit,
            confidenceLevel: fit ? .high : .medium,
            warnings: warnings,
            isStorageBlocked: storageBlocked
        )
    }

    func formattedDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "—"
    }

    func formattedBytes(_ value: Int64) -> String {
        let measurement = Measurement(value: Double(value), unit: UnitInformationStorage.bytes)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .short
        return formatter.string(from: measurement)
    }

    private func baseQuant(ramGB: Double, params: Int64) -> QuantType {
        let b = Double(params) / 1_000_000_000
        if ramGB >= 12 {
            if b <= 7 { return .q8_0 }
            if b <= 13 { return .q5_k_m }
            return .q4_k_m
        }
        if ramGB >= 8 {
            if b <= 7 { return .q5_k_m }
            if b <= 13 { return .q4_k_m }
            return .q3_k_m
        }
        return .q4_0
    }

    private func downgraded(_ type: QuantType) -> QuantType {
        switch type {
        case .q8_0: return .q6_k
        case .q6_k: return .q5_k_m
        case .q5_k_m: return .q4_k_m
        case .q4_k_m: return .q4_0
        case .q4_0: return .q3_k_m
        case .q3_k_m: return .q3_k_m
        }
    }

    private func alternatives(for type: QuantType) -> [QuantType] {
        let preferredOrder: [QuantType] = [.q5_k_m, .q4_k_m, .q8_0, .q6_k, .q4_0, .q3_k_m]
        return preferredOrder.filter { $0 != type }
    }

    private func explanation(ramGB: Double, params: Int64, quant: QuantType) -> String {
        let b = Double(params) / 1_000_000_000
        return "Detected \(String(format: "%.0f", ramGB)) GB RAM and ~\(String(format: "%.1f", b))B params. Suggested \(quant.rawValue) for balanced output quality and runtime on this device tier."
    }
}
