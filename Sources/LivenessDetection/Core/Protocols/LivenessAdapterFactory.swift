import Foundation

/// Protocol for creating vendor adapters
public protocol LivenessAdapterFactory: Sendable {
    func createAdapter(for configuration: any LivenessConfiguration) -> (any LivenessVendorAdapter)?
}
