import Foundation
import Combine

@MainActor
@Observable
final class ThermalMonitor {
    var currentState: ProcessInfo.ThermalState = ProcessInfo.processInfo.thermalState

    private var cancellable: AnyCancellable?

    func start() {
        stop()
        cancellable = Timer
            .publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.currentState = ProcessInfo.processInfo.thermalState
            }
    }

    func stop() {
        cancellable?.cancel()
        cancellable = nil
    }
}
