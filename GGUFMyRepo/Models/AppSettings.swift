import Foundation

enum UploadChunkSize: Int, CaseIterable, Codable {
    case mb4 = 4
    case mb8 = 8
    case mb16 = 16

    var bytes: Int { rawValue * 1024 * 1024 }
}

enum NetworkPolicy: String, CaseIterable, Codable {
    case any
    case wifiOnly
}

enum LogVerbosity: String, CaseIterable, Codable {
    case minimal
    case normal
    case verbose
}

/// Centralized app settings that are feasible on iOS and relevant for on-device quantization workflows.
struct AppSettings: Codable {
    // Quantization defaults
    var defaultThreads: Int = max(1, ProcessInfo.processInfo.activeProcessorCount - 1)
    var autoShowRecommendationCard: Bool = true
    var autoDeleteSourceAfterSuccess: Bool = false
    var autoDeleteOutputAfterUpload: Bool = false

    // Download
    var maxConcurrentDownloads: Int = 1
    var autoResumeDownloadsOnLaunch: Bool = true
    var preferredDownloadSubdirectory: String = "Models"

    // Upload
    var defaultOutputVisibilityPrivate: Bool = false
    var uploadChunkSize: UploadChunkSize = .mb8
    var uploadPolicy: NetworkPolicy = .wifiOnly

    // Runtime safety
    var pauseOnThermalCritical: Bool = true
    var warnOnThermalSerious: Bool = true
    var minimumFreeSpaceMultiplier: Double = 2.0

    // UX
    var showTensorNames: Bool = true
    var compactMode: Bool = false
    var logVerbosity: LogVerbosity = .normal

    // Notifications
    var notifyOnDownloadCompletion: Bool = true
    var notifyOnQuantCompletion: Bool = true
    var notifyOnUploadCompletion: Bool = true
    var notifyOnFailure: Bool = true
}
