import Foundation

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