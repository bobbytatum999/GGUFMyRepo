import Foundation

struct DownloadSnapshot: Codable {
    let sourceURL: URL
    let destinationURL: URL
    let resumeDataPath: String
}

@MainActor
@Observable
final class DownloadManager {
    var progress: Double = 0
    var speedBytesPerSecond: Double = 0
    var etaSeconds: Double?
    var downloadedBytes: Int64 = 0
    var totalBytes: Int64 = 0

    private var startedAt: Date?
    private var task: URLSessionDownloadTask?
    private var session: URLSession!
    private let persistenceURL: URL
    private var currentSnapshot: DownloadSnapshot?
    private let delegateProxy = DownloadDelegateProxy()

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        persistenceURL = docs.appending(path: "download-snapshot.json")

        let config = URLSessionConfiguration.background(withIdentifier: "com.ggufmyrepo.download")
        config.waitsForConnectivity = true
        config.sessionSendsLaunchEvents = true

        session = URLSession(configuration: config, delegate: delegateProxy, delegateQueue: nil)
        delegateProxy.owner = self
    }

    func startDownload(from url: URL, to destination: URL) {
        startedAt = Date()
        progress = 0
        speedBytesPerSecond = 0
        etaSeconds = nil
        downloadedBytes = 0
        totalBytes = 0

        task = session.downloadTask(with: url)
        task?.resume()

        currentSnapshot = DownloadSnapshot(
            sourceURL: url,
            destinationURL: destination,
            resumeDataPath: persistenceURL.deletingLastPathComponent().appending(path: "download.resume").path
        )
        persistSnapshot()
    }

    func cancelAndStoreResumeData() {
        task?.cancel(byProducingResumeData: { [weak self] resumeData in
            guard let self, let resumeData, let snapshot = self.currentSnapshot else { return }
            try? resumeData.write(to: URL(fileURLWithPath: snapshot.resumeDataPath), options: .atomic)
            self.persistSnapshot()
        })
        task = nil
    }

    func autoResumeIfPossible() {
        guard
            let data = try? Data(contentsOf: persistenceURL),
            let snapshot = try? JSONDecoder().decode(DownloadSnapshot.self, from: data),
            let resumeData = try? Data(contentsOf: URL(fileURLWithPath: snapshot.resumeDataPath))
        else { return }

        currentSnapshot = snapshot
        task = session.downloadTask(withResumeData: resumeData)
        task?.resume()
    }

    fileprivate func handleProgress(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpected: Int64) {
        downloadedBytes = totalBytesWritten
        totalBytes = max(totalBytesExpected, 0)
        if totalBytes > 0 {
            progress = Double(totalBytesWritten) / Double(totalBytes)
        }

        if let startedAt {
            let elapsed = Date().timeIntervalSince(startedAt)
            if elapsed > 0 {
                speedBytesPerSecond = Double(totalBytesWritten) / elapsed
                if speedBytesPerSecond > 0, totalBytes > 0 {
                    let remaining = Double(totalBytes - totalBytesWritten)
                    etaSeconds = remaining / speedBytesPerSecond
                }
            }
        }
    }

    fileprivate func handleCompletion(tempURL: URL) {
        guard let snapshot = currentSnapshot else { return }
        do {
            let destination = snapshot.destinationURL
            try? FileManager.default.removeItem(at: destination)
            try FileManager.default.moveItem(at: tempURL, to: destination)
            progress = 1
            cleanupPersistence()
        } catch {
            // Keep snapshot data for retry.
        }
    }

    private func persistSnapshot() {
        guard let currentSnapshot else { return }
        if let data = try? JSONEncoder().encode(currentSnapshot) {
            try? data.write(to: persistenceURL, options: .atomic)
        }
    }

    private func cleanupPersistence() {
        guard let currentSnapshot else { return }
        try? FileManager.default.removeItem(atPath: currentSnapshot.resumeDataPath)
        try? FileManager.default.removeItem(at: persistenceURL)
        self.currentSnapshot = nil
    }
}

private final class DownloadDelegateProxy: NSObject, URLSessionDownloadDelegate {
    weak var owner: DownloadManager?

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        Task { @MainActor in
            owner?.handleProgress(bytesWritten: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpected: totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        Task { @MainActor in
            owner?.handleCompletion(tempURL: location)
        }
    }
}
