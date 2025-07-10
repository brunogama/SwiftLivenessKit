import Foundation

/// Configuration protocol for vendor-specific settings
public protocol LivenessConfiguration: Sendable {
    var vendorName: String { get }
    var timeout: TimeInterval { get }
    var additionalSettings: [String: Any] { get }
}
