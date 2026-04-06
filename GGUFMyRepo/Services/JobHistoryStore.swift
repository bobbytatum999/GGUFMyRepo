import Foundation

struct JobHistoryStore {
    private let fileURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "job-history.json")

    func load() -> [QuantJob] { [] }
    func save(_ jobs: [QuantJob]) throws { _ = fileURL }
}
