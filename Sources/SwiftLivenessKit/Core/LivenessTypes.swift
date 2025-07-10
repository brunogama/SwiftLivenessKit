import UIKit

// MARK: - Core Types

/// Unified error type for all liveness detection failures
public enum LivenessError: Error, Equatable {
    case configurationFailed(reason: String)
    case timeout(vendor: String)
    case vendorSpecific(vendor: String, code: Int, message: String)
    case noAvailableVendor
    case cancelled
    case invalidState(String)
    case viewControllerDeallocated
}

/// Unified result type for liveness detection
public struct LivenessResult: Sendable {
    public let vendor: String
    public let confidence: Double
    public let metadata: [String: Any]
    public let timestamp: Date
    
    public init(vendor: String, confidence: Double, metadata: [String: Any] = [:]) {
        self.vendor = vendor
        self.confidence = confidence
        self.metadata = metadata
        self.timestamp = Date()
    }
}
