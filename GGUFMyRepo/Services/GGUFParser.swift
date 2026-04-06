import Foundation

enum GGUFParserError: Error { case invalidMagic, unsupportedVersion, malformed }

struct GGUFParser {
    func parseHeader(at url: URL) throws -> GGUFMetadata {
        let file = try FileHandle(forReadingFrom: url)
        defer { try? file.close() }

        let magic: UInt32 = try read(file)
        guard magic == 0x46554747 else { throw GGUFParserError.invalidMagic }

        let version: UInt32 = try read(file)
        guard version == 3 else { throw GGUFParserError.unsupportedVersion }

        let tensorCount: UInt64 = try read(file)
        let metadataCount: UInt64 = try read(file)

        var parameterCount: Int64?
        var architecture: String?
        var name: String?
        var fileType: Int32?

        for _ in 0..<metadataCount {
            let key = try readString(file)
            let valueType: UInt32 = try read(file)
            switch key {
            case "general.parameter_count": parameterCount = Int64(try readNumericValue(file, type: valueType))
            case "general.architecture": architecture = try readStringValue(file, type: valueType)
            case "general.name": name = try readStringValue(file, type: valueType)
            case "general.file_type": fileType = Int32(try readNumericValue(file, type: valueType))
            default: try skipValue(file, type: valueType)
            }
            if parameterCount != nil, architecture != nil, name != nil, fileType != nil { break }
        }

        return GGUFMetadata(parameterCount: parameterCount, architecture: architecture, name: name, fileType: fileType, tensorCount: tensorCount, metadataCount: metadataCount)
    }

    private func read<T>(_ file: FileHandle) throws -> T {
        let size = MemoryLayout<T>.size
        guard let data = try file.read(upToCount: size), data.count == size else { throw GGUFParserError.malformed }
        return data.withUnsafeBytes { $0.load(as: T.self) }
    }

    private func readString(_ file: FileHandle) throws -> String {
        let length: UInt64 = try read(file)
        guard let data = try file.read(upToCount: Int(length)), data.count == Int(length), let s = String(data: data, encoding: .utf8) else {
            throw GGUFParserError.malformed
        }
        return s
    }

    private func readStringValue(_ file: FileHandle, type: UInt32) throws -> String {
        guard type == 8 else { try skipValue(file, type: type); throw GGUFParserError.malformed }
        return try readString(file)
    }

    private func readNumericValue(_ file: FileHandle, type: UInt32) throws -> Int64 {
        switch type {
        case 4: return Int64(try read(file) as UInt32)
        case 5: return Int64(try read(file) as Int32)
        case 10: return Int64(try read(file) as UInt64)
        case 11: return Int64(try read(file) as Int64)
        default: try skipValue(file, type: type); throw GGUFParserError.malformed
        }
    }

    private func skipValue(_ file: FileHandle, type: UInt32) throws {
        let skipSizes: [UInt32: Int] = [0:1,1:1,2:2,3:2,4:4,5:4,6:4,7:1,10:8,11:8]
        if type == 8 {
            _ = try readString(file)
            return
        }
        if let count = skipSizes[type] {
            _ = try file.read(upToCount: count)
            return
        }
        throw GGUFParserError.malformed
    }
}
