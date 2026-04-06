import XCTest
@testable import GGUFCore

final class RecommendationEngineTests: XCTestCase {
    func test12GBAnd7BRecommendsQ8() {
        let engine = RecommendationEngine()
        let device = DeviceSpec(
            ramBytes: 12 * 1024 * 1024 * 1024,
            availableRAMBytes: 8 * 1024 * 1024 * 1024,
            thermal: .nominal
        )

        let rec = engine.recommend(
            device: device,
            inputFileSize: 10 * 1024 * 1024 * 1024,
            parameterCount: 7_000_000_000,
            availableStorage: 100 * 1024 * 1024 * 1024
        )

        XCTAssertEqual(rec.suggestedType, .q8_0)
    }

    func testThermalDowngradeApplied() {
        let engine = RecommendationEngine()
        let device = DeviceSpec(
            ramBytes: 12 * 1024 * 1024 * 1024,
            availableRAMBytes: 8 * 1024 * 1024 * 1024,
            thermal: .serious
        )

        let rec = engine.recommend(
            device: device,
            inputFileSize: 10 * 1024 * 1024 * 1024,
            parameterCount: 7_000_000_000,
            availableStorage: 100 * 1024 * 1024 * 1024
        )

        XCTAssertEqual(rec.suggestedType, .q6_k)
    }

    func testStorageBlock() {
        let engine = RecommendationEngine()
        let device = DeviceSpec(ramBytes: 8 * 1024 * 1024 * 1024, availableRAMBytes: 5 * 1024 * 1024 * 1024, thermal: .nominal)

        let rec = engine.recommend(
            device: device,
            inputFileSize: 4 * 1024 * 1024 * 1024,
            parameterCount: 7_000_000_000,
            availableStorage: 3 * 1024 * 1024 * 1024
        )

        XCTAssertTrue(rec.isStorageBlocked)
    }
}
