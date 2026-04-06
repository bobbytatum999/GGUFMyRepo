import XCTest
@testable import GGUFMyRepo

final class QuantRecommendationEngineTests: XCTestCase {
    func test12GB7BRecommendsQ8() {
        let profile = DeviceProfile(machine: "iPhone18,4", deviceName: "iPhone 17 Pro", chipName: "A19 Pro", ramBytes: 12 * 1024 * 1024 * 1024, tier: .pro)
        let device = DeviceInfo(
            machine: "iPhone18,4",
            totalRAMBytes: profile.ramBytes,
            logicalCPUs: 8,
            physicalCPUs: 6,
            availableRAMBytes: 6 * 1024 * 1024 * 1024,
            thermalState: .nominal,
            deviceName: "Test Device",
            systemVersion: "26.0",
            profile: profile
        )

        let engine = QuantRecommendationEngine()
        let result = engine.recommend(
            device: device,
            inputFileSize: 14 * 1024 * 1024 * 1024,
            parameterCount: 7_000_000_000,
            availableStorage: 100 * 1024 * 1024 * 1024
        )

        XCTAssertEqual(result.suggestedType, .q8_0)
    }

    func testStorageBlockTriggers() {
        let profile = DeviceProfile(machine: "iPhone15,4", deviceName: "iPhone 15", chipName: "A16", ramBytes: 6 * 1024 * 1024 * 1024, tier: .standard)
        let device = DeviceInfo(
            machine: "iPhone15,4",
            totalRAMBytes: profile.ramBytes,
            logicalCPUs: 6,
            physicalCPUs: 6,
            availableRAMBytes: 2 * 1024 * 1024 * 1024,
            thermalState: .nominal,
            deviceName: "Test Device",
            systemVersion: "26.0",
            profile: profile
        )

        let engine = QuantRecommendationEngine()
        let result = engine.recommend(
            device: device,
            inputFileSize: 4 * 1024 * 1024 * 1024,
            parameterCount: 7_000_000_000,
            availableStorage: 3 * 1024 * 1024 * 1024
        )

        XCTAssertTrue(result.isStorageBlocked)
    }
}
