import Foundation

@Observable
final class DownloadManager {
    var progress: Double = 0
    var speedBytesPerSecond: Double = 0

    func download(from url: URL, to destination: URL) async throws {
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: tempURL, to: destination)
        progress = 1
    }
}
