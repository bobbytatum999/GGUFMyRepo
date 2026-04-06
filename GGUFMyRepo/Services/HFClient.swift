import Foundation

struct HFClient {
    private let baseURL = URL(string: "https://huggingface.co")!

    func searchModels(query: String) async throws -> [HFModel] {
        var comps = URLComponents(url: baseURL.appending(path: "/api/models"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "search", value: query),
            .init(name: "filter", value: "gguf"),
            .init(name: "limit", value: "30"),
            .init(name: "sort", value: "downloads")
        ]
        let (data, _) = try await URLSession.shared.data(from: comps.url!)
        return try JSONDecoder().decode([HFModel].self, from: data)
    }
}
