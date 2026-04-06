import XCTest
@testable import GGUFCore

final class GGUFParserCoreTests: XCTestCase {
    func testInvalidMagicThrows() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "bad-magic.gguf")
        try Data([0, 1, 2, 3, 4, 5, 6, 7]).write(to: url)

        XCTAssertThrowsError(try GGUFParser().parseHeader(at: url))
    }
}
