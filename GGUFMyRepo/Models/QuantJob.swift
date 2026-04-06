import Foundation

enum JobPhase: Codable {
    case idle
    case downloading(progress: Float, speed: Double)
    case quantizing(progress: Float, currentTensor: String, eta: TimeInterval)
    case uploading(progress: Float, speed: Double)
    case complete(outputRepo: String, inputSize: Int64, outputSize: Int64)
    case failed(phase: String, error: String)
    case cancelled
}

@Observable
final class QuantJob: Identifiable, Codable {
    let id: UUID
    var modelId: String
    var sourceFile: String
    var quantType: QuantType
    var outputRepo: String
    var phase: JobPhase
    var createdAt: Date
    var deviceModel: String
    var chipName: String

    init(
        id: UUID = UUID(),
        modelId: String,
        sourceFile: String,
        quantType: QuantType,
        outputRepo: String,
        phase: JobPhase = .idle,
        createdAt: Date = Date(),
        deviceModel: String,
        chipName: String
    ) {
        self.id = id
        self.modelId = modelId
        self.sourceFile = sourceFile
        self.quantType = quantType
        self.outputRepo = outputRepo
        self.phase = phase
        self.createdAt = createdAt
        self.deviceModel = deviceModel
        self.chipName = chipName
    }
}
