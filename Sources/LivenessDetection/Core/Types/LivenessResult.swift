import Foundation

public enum LivenessMetadataValue: Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case date(Date)
    // Add more cases as needed that are Sendable
}

/// Unified result type for liveness detection
public struct LivenessResult: Sendable {
    public let vendor: String
    public let confidence: Double
    public let metadata: [String: LivenessMetadataValue]
    public let timestamp: Date
    
    public init(vendor: String, confidence: Double, metadata: [String: LivenessMetadataValue] = [:]) {
        self.vendor = vendor
        self.confidence = confidence
        self.metadata = metadata
        self.timestamp = Date()
    }
}
