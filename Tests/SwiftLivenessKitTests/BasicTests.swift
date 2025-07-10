import XCTest
@testable import SwiftLivenessKit

// MARK: - Basic Tests

final class SwiftLivenessKitTests: XCTestCase {
    
    func testLivenessResultCreation() {
        // Given
        let vendor = "TestVendor"
        let confidence = 0.95
        let metadata = ["key": "value"]
        
        // When
        let result = LivenessResult(
            vendor: vendor,
            confidence: confidence,
            metadata: metadata
        )
        
        // Then
        XCTAssertEqual(result.vendor, vendor)
        XCTAssertEqual(result.confidence, confidence)
        XCTAssertNotNil(result.timestamp)
    }
    
    func testLivenessErrorEquality() {
        // Given
        let error1 = LivenessError.timeout(vendor: "VendorA")
        let error2 = LivenessError.timeout(vendor: "VendorA")
        let error3 = LivenessError.timeout(vendor: "VendorB")
        
        // Then
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
}