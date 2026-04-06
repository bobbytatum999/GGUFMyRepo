import Foundation

struct HFModel: Decodable, Identifiable {
    let id: String
    let likes: Int?
    let downloads: Int?
    let pipelineTag: String?
    let tags: [String]?
}
