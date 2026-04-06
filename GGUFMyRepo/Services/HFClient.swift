import Foundation

struct HFWhoAmI: Decodable {
    let name: String
    let fullname: String?
    let avatarUrl: String?
}

enum HFClientError: Error {
    case invalidResponse
}

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
        var request = URLRequest(url: comps.url!)
        request.timeoutInterval = 30
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([HFModel].self, from: data)
    }

    func whoAmI(token: String) async throws -> HFWhoAmI {
        var request = URLRequest(url: baseURL.appending(path: "/api/whoami-v2"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw HFClientError.invalidResponse }
        return try JSONDecoder().decode(HFWhoAmI.self, from: data)
    }

    func createRepo(token: String, repoId: String, isPrivate: Bool) async throws {
        var request = URLRequest(url: baseURL.appending(path: "/api/repos/create"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "name": repoId.split(separator: "/").last.map(String.init) ?? repoId,
            "private": isPrivate,
            "type": "model"
        ])

        let (_, response) = try await URLSession.shared.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode ?? 500
        guard (200...299).contains(code) || code == 409 else { throw HFClientError.invalidResponse }
    }

    func uploadFile(token: String, repoId: String, localFileURL: URL, remoteFileName: String) async throws {
        let url = baseURL
            .appending(path: "/\(repoId)")
            .appending(path: "/upload/main/\(remoteFileName)")

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let data = try Data(contentsOf: localFileURL)
        request.httpBody = data

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw HFClientError.invalidResponse
        }
    }
}
