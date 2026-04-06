import XCTest
@testable import GGUFCore

final class GGUFParserCoreTests: XCTestCase {
    func testInvalidMagicThrows() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "bad-magic.gguf")
        try Data([0, 1, 2, 3, 4, 5, 6, 7]).write(to: url)

        XCTAssertThrowsError(try GGUFParser().parseHeader(at: url))
    }

    func testParsesCoreMetadataKeys() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "metadata.gguf")
        try makeSampleGGUF().write(to: url)

        let parsed = try GGUFParser().parseHeader(at: url)
        XCTAssertEqual(parsed.tensorCount, 10)
        XCTAssertEqual(parsed.metadataCount, 4)
        XCTAssertEqual(parsed.parameterCount, 7_000_000_000)
        XCTAssertEqual(parsed.architecture, "llama")
        XCTAssertEqual(parsed.name, "Llama-3-8B")
        XCTAssertEqual(parsed.fileType, 1)
    }

    private func makeSampleGGUF() -> Data {
        var d = Data()

        append(UInt32(0x46554747), to: &d) // magic GGUF
        append(UInt32(3), to: &d) // version
        append(UInt64(10), to: &d) // tensors
        append(UInt64(4), to: &d) // metadata kv count

        appendKV(key: "general.parameter_count", type: 10, uint64: 7_000_000_000, into: &d)
        appendKV(key: "general.architecture", type: 8, string: "llama", into: &d)
        appendKV(key: "general.name", type: 8, string: "Llama-3-8B", into: &d)
        appendKV(key: "general.file_type", type: 4, uint32: 1, into: &d)

        return d
    }

    private func appendKV(key: String, type: UInt32, uint64: UInt64? = nil, uint32: UInt32? = nil, string: String? = nil, into data: inout Data) {
        appendString(key, to: &data)
        append(type, to: &data)

        switch type {
        case 10:
            append(uint64 ?? 0, to: &data)
        case 4:
            append(uint32 ?? 0, to: &data)
        case 8:
            appendString(string ?? "", to: &data)
        default:
            break
        }
    }

    private func appendString(_ value: String, to data: inout Data) {
        let bytes = Array(value.utf8)
        append(UInt64(bytes.count), to: &data)
        data.append(contentsOf: bytes)
    }

    private func append<T: FixedWidthInteger>(_ value: T, to data: inout Data) {
        var le = value.littleEndian
        withUnsafeBytes(of: &le) { data.append(contentsOf: $0) }
    }
}
