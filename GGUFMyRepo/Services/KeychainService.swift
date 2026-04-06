import Foundation

struct KeychainService {
    func save(token: String) throws {}
    func readToken() -> String? { nil }
    func clearToken() throws {}
}
