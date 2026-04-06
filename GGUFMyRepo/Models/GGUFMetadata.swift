import Foundation

struct GGUFMetadata: Codable, Hashable {
    let parameterCount: Int64?
    let architecture: String?
    let name: String?
    let fileType: Int32?
    let tensorCount: UInt64
    let metadataCount: UInt64
}
