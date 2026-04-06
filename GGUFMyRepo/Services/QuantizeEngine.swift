import Foundation

struct QuantizeProgress: Sendable {
    let progress: Float
    let tensorName: String
    let tensorsProcessed: Int
    let tensorsTotal: Int
    let thermalState: ProcessInfo.ThermalState
}

enum QuantizeError: Error { case failed(code: Int32) }

private final class QuantizeProgressBox {
    let continuation: AsyncThrowingStream<QuantizeProgress, Error>.Continuation

    init(continuation: AsyncThrowingStream<QuantizeProgress, Error>.Continuation) {
        self.continuation = continuation
    }
}

actor QuantizeEngine {
    func quantize(input: URL, output: URL, type: QuantType, threads: Int) -> AsyncThrowingStream<QuantizeProgress, Error> {
        AsyncThrowingStream { continuation in
            let progressBox = QuantizeProgressBox(continuation: continuation)
            let unmanaged = Unmanaged.passRetained(progressBox)

            Task.detached(priority: .userInitiated) { [self] in
                defer { unmanaged.release() }
                do {
                    try await self.runQuantization(input: input, output: output, type: type, threads: threads, context: unmanaged.toOpaque())
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func runQuantization(input: URL, output: URL, type: QuantType, threads: Int, context: UnsafeMutableRawPointer) async throws {
        _ = (input, output, type, threads)

        // Placeholder progression loop used until llama_model_quantize C callback is wired.
        // Keep this callback-compatible context model so swapping in C API is straightforward.
        for index in 0...100 {
            try await Task.sleep(nanoseconds: 45_000_000)
            quantizeProgressBridge(Float(index) / 100, "tensor_\(index)", index, 100, context)
        }
    }
}

private func quantizeProgressBridge(
    _ progress: Float,
    _ tensorName: String,
    _ processed: Int,
    _ total: Int,
    _ context: UnsafeMutableRawPointer
) {
    let box = Unmanaged<QuantizeProgressBox>.fromOpaque(context).takeUnretainedValue()
    box.continuation.yield(
        QuantizeProgress(
            progress: progress,
            tensorName: tensorName,
            tensorsProcessed: processed,
            tensorsTotal: total,
            thermalState: ProcessInfo.processInfo.thermalState
        )
    )
}
