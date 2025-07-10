import XCTest
@testable import LivenessDetection

final class LivenessDetectionTests: XCTestCase {
    
    func testMockAdapterConfiguration() async throws {
        // Given
        let adapter = MockLivenessAdapter()
        let config = MockConfiguration(shouldSucceed: true)
        
        // When
        try await adapter.configure(with: config)
        
        // Then
        let isConfigured = await adapter.isConfigured
        XCTAssertTrue(isConfigured)
    }
    
    func testMockAdapterSuccess() async throws {
        // Given
        let adapter = MockLivenessAdapter()
        let config = MockConfiguration(shouldSucceed: true, simulatedDelay: 0.1)
        try await adapter.configure(with: config)
        
        let mockViewController = UIViewController()
        
        // When
        let stream = try await adapter.startLivenessCheck(in: mockViewController)
        var events: [LivenessEvent] = []
        
        for try await event in stream {
            events.append(event)
        }
        
        // Then
        XCTAssertFalse(events.isEmpty)
        if case .completed(let result) = events.last {
            XCTAssertEqual(result.vendor, "Mock")
            XCTAssertEqual(result.confidence, 1.0)
        } else {
            XCTFail("Expected completion event")
        }
    }
}