import Foundation

enum JobPhase: Codable {
    case idle
    case downloading(progress: Float, speed: Double)
    case quantizing(progress: Float, currentTensor: String, eta: TimeInterval)
    case uploading(progress: Float, speed: Double)
    case complete(outputRepo: String, inputSize: Int64, outputSize: Int64)
    case failed(phase: String, error: String)
    case cancelled

    private enum CodingKeys: String, CodingKey {
        case state, progress, speed, currentTensor, eta, outputRepo, inputSize, outputSize, phase, error
    }

    private enum State: String, Codable {
        case idle, downloading, quantizing, uploading, complete, failed, cancelled
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .idle:
            try container.encode(State.idle, forKey: .state)
        case .downloading(let progress, let speed):
            try container.encode(State.downloading, forKey: .state)
            try container.encode(progress, forKey: .progress)
            try container.encode(speed, forKey: .speed)
        case .quantizing(let progress, let currentTensor, let eta):
            try container.encode(State.quantizing, forKey: .state)
            try container.encode(progress, forKey: .progress)
            try container.encode(currentTensor, forKey: .currentTensor)
            try container.encode(eta, forKey: .eta)
        case .uploading(let progress, let speed):
            try container.encode(State.uploading, forKey: .state)
            try container.encode(progress, forKey: .progress)
            try container.encode(speed, forKey: .speed)
        case .complete(let outputRepo, let inputSize, let outputSize):
            try container.encode(State.complete, forKey: .state)
            try container.encode(outputRepo, forKey: .outputRepo)
            try container.encode(inputSize, forKey: .inputSize)
            try container.encode(outputSize, forKey: .outputSize)
        case .failed(let phase, let error):
            try container.encode(State.failed, forKey: .state)
            try container.encode(phase, forKey: .phase)
            try container.encode(error, forKey: .error)
        case .cancelled:
            try container.encode(State.cancelled, forKey: .state)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let state = try container.decode(State.self, forKey: .state)

        switch state {
        case .idle:
            self = .idle
        case .downloading:
            self = .downloading(progress: try container.decode(Float.self, forKey: .progress), speed: try container.decode(Double.self, forKey: .speed))
        case .quantizing:
            self = .quantizing(
                progress: try container.decode(Float.self, forKey: .progress),
                currentTensor: try container.decode(String.self, forKey: .currentTensor),
                eta: try container.decode(TimeInterval.self, forKey: .eta)
            )
        case .uploading:
            self = .uploading(progress: try container.decode(Float.self, forKey: .progress), speed: try container.decode(Double.self, forKey: .speed))
        case .complete:
            self = .complete(
                outputRepo: try container.decode(String.self, forKey: .outputRepo),
                inputSize: try container.decode(Int64.self, forKey: .inputSize),
                outputSize: try container.decode(Int64.self, forKey: .outputSize)
            )
        case .failed:
            self = .failed(
                phase: try container.decode(String.self, forKey: .phase),
                error: try container.decode(String.self, forKey: .error)
            )
        case .cancelled:
            self = .cancelled
        }
    }
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
