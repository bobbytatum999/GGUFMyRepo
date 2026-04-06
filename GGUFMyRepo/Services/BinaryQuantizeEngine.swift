import Foundation
import Darwin

/// Non-App-Store-safe helper that executes a bundled `llama-quantize` binary via `posix_spawn`.
/// Intended for sideload/dev builds where shipping an executable payload is acceptable.
actor BinaryQuantizeEngine {
    struct OutputEvent: Sendable {
        let line: String
        let progress: Double?
    }

    enum EngineError: Error {
        case binaryMissing
        case spawnFailed(Int32)
        case waitFailed
        case nonZeroExit(Int32)
    }

    func quantize(
        binaryURL: URL,
        inputURL: URL,
        outputURL: URL,
        quantType: QuantType,
        threads: Int
    ) -> AsyncThrowingStream<OutputEvent, Error> {
        AsyncThrowingStream { continuation in
            Task.detached(priority: .userInitiated) {
                do {
                    try self.run(binaryURL: binaryURL, inputURL: inputURL, outputURL: outputURL, quantType: quantType, threads: threads, continuation: continuation)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func run(
        binaryURL: URL,
        inputURL: URL,
        outputURL: URL,
        quantType: QuantType,
        threads: Int,
        continuation: AsyncThrowingStream<OutputEvent, Error>.Continuation
    ) throws {
        guard FileManager.default.fileExists(atPath: binaryURL.path()) else {
            throw EngineError.binaryMissing
        }

        chmod(binaryURL.path(), 0o755)

        var pipefds: [Int32] = [0, 0]
        guard pipe(&pipefds) == 0 else { throw EngineError.spawnFailed(errno) }

        defer {
            close(pipefds[0])
            close(pipefds[1])
        }

        var fileActions = posix_spawn_file_actions_t()
        posix_spawn_file_actions_init(&fileActions)
        defer { posix_spawn_file_actions_destroy(&fileActions) }

        posix_spawn_file_actions_adddup2(&fileActions, pipefds[1], STDOUT_FILENO)
        posix_spawn_file_actions_adddup2(&fileActions, pipefds[1], STDERR_FILENO)

        let args = [
            binaryURL.path(),
            "--threads", "\(threads)",
            inputURL.path(),
            outputURL.path(),
            quantType.rawValue
        ]

        let cArgs: [UnsafeMutablePointer<CChar>?] = args.map { strdup($0) } + [nil]
        defer { cArgs.forEach { free($0) } }

        var pid: pid_t = 0
        let status = posix_spawn(&pid, binaryURL.path(), &fileActions, nil, UnsafeMutablePointer(mutating: cArgs), environ)
        guard status == 0 else { throw EngineError.spawnFailed(status) }

        close(pipefds[1])
        try streamOutput(readFD: pipefds[0], continuation: continuation)

        var exitStatus: Int32 = 0
        guard waitpid(pid, &exitStatus, 0) >= 0 else { throw EngineError.waitFailed }
        guard WIFEXITED(exitStatus) && WEXITSTATUS(exitStatus) == 0 else {
            throw EngineError.nonZeroExit(exitStatus)
        }
    }

    private func streamOutput(readFD: Int32, continuation: AsyncThrowingStream<OutputEvent, Error>.Continuation) throws {
        var buffer = [UInt8](repeating: 0, count: 4096)
        var carry = Data()

        while true {
            let bytes = read(readFD, &buffer, buffer.count)
            if bytes == 0 { break }
            if bytes < 0 { break }

            carry.append(buffer, count: bytes)

            while let range = carry.firstRange(of: Data([0x0A])) {
                let lineData = carry.subdata(in: 0..<range.lowerBound)
                carry.removeSubrange(0...range.lowerBound)

                if let line = String(data: lineData, encoding: .utf8) {
                    continuation.yield(OutputEvent(line: line, progress: parseProgress(from: line)))
                }
            }
        }

        if !carry.isEmpty, let trailing = String(data: carry, encoding: .utf8) {
            continuation.yield(OutputEvent(line: trailing, progress: parseProgress(from: trailing)))
        }
    }

    private func parseProgress(from line: String) -> Double? {
        let pattern = #"([0-9]{1,3})%"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let ns = line as NSString
        guard let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: ns.length)) else { return nil }
        let raw = ns.substring(with: match.range(at: 1))
        guard let value = Double(raw) else { return nil }
        return min(max(value / 100.0, 0), 1)
    }
}
