import XCTest
@testable import GGUFMyRepo

final class GGUFParserTests: XCTestCase {
    func testRejectsInvalidMagic() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "invalid-magic.gguf")
        try Data([0, 1, 2, 3]).write(to: url)

        let parser = GGUFParser()
        XCTAssertThrowsError(try parser.parseHeader(at: url))
    }
}
