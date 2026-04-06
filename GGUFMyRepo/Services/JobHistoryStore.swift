import Foundation

struct JobHistoryStore {
    private let fileURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "job-history.json")

    func load() -> [QuantJob] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        do {
            return try JSONDecoder().decode([QuantJob].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ jobs: [QuantJob]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(jobs)
        try data.write(to: fileURL, options: .atomic)
    }

    func clear() throws {
        if FileManager.default.fileExists(atPath: fileURL.path()) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
