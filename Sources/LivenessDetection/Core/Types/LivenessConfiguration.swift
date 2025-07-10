import Foundation

/// Sendable value type for configuration settings
public enum SendableSettingsValue: Sendable, Equatable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([SendableSettingsValue])
    case dictionary([String: SendableSettingsValue])
}

/// Configuration protocol for vendor-specific settings
public protocol LivenessConfiguration: Sendable {
    var vendorName: String { get }
    var timeout: TimeInterval { get }
    var additionalSettings: [String: SendableSettingsValue] { get }
}
