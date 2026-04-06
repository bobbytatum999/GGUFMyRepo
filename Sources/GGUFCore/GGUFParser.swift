import Foundation

public struct GGUFMetadata: Equatable {
    public let parameterCount: Int64?
    public let architecture: String?
    public let name: String?
    public let fileType: Int32?
    public let tensorCount: UInt64
    public let metadataCount: UInt64

    public init(parameterCount: Int64?, architecture: String?, name: String?, fileType: Int32?, tensorCount: UInt64, metadataCount: UInt64) {
        self.parameterCount = parameterCount
        self.architecture = architecture
        self.name = name
        self.fileType = fileType
        self.tensorCount = tensorCount
        self.metadataCount = metadataCount
    }
}

public enum GGUFParserError: Error {
    case invalidMagic
    case unsupportedVersion
    case malformed
}

public struct GGUFParser {
    public init() {}

    public func parseHeader(at url: URL) throws -> GGUFMetadata {
        let file = try FileHandle(forReadingFrom: url)
        defer { try? file.close() }

        let magic: UInt32 = try read(file)
        guard magic == 0x46554747 else { throw GGUFParserError.invalidMagic }

        let version: UInt32 = try read(file)
        guard version == 3 else { throw GGUFParserError.unsupportedVersion }

        let tensorCount: UInt64 = try read(file)
        let metadataCount: UInt64 = try read(file)

        return GGUFMetadata(
            parameterCount: nil,
            architecture: nil,
            name: nil,
            fileType: nil,
            tensorCount: tensorCount,
            metadataCount: metadataCount
        )
    }

    private func read(_ file: FileHandle, count: Int) throws -> Data {
        guard let data = try file.read(upToCount: count), data.count == count else {
            throw GGUFParserError.malformed
        }
        return data
    }

    private func read<T: FixedWidthInteger>(_ file: FileHandle) throws -> T {
        let data = try read(file, count: MemoryLayout<T>.size)
        return data.withUnsafeBytes { raw in
            let value = raw.loadUnaligned(as: T.self)
            return T(littleEndian: value)
        }
    }
}
