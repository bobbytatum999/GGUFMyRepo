import Foundation

struct QuantizeProgress: Sendable {
    let progress: Float
    let tensorName: String
}

enum QuantizeError: Error { case failed(code: Int32) }

actor QuantizeEngine {
    func quantize(input: URL, output: URL, type: QuantType, threads: Int) -> AsyncThrowingStream<QuantizeProgress, Error> {
        AsyncThrowingStream { continuation in
            Task.detached(priority: .userInitiated) {
                do {
                    for step in 0...100 {
                        try await Task.sleep(nanoseconds: 30_000_000)
                        continuation.yield(.init(progress: Float(step) / 100, tensorName: "tensor_\(step)"))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
                _ = (input, output, type, threads)
            }
        }
    }
}
