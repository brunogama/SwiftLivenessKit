import UIKit

/// Main protocol that all vendor adapters must implement
public protocol LivenessVendorAdapter: Actor {
    associatedtype Configuration: LivenessConfiguration
    
    /// Configure the adapter with vendor-specific settings
    func configure(with configuration: Configuration) async throws
    
    /// Start liveness detection with the provided view controller
    func startLivenessCheck(
        in viewController: UIViewController
    ) async throws -> AsyncThrowingStream<LivenessEvent, Error>
    
    /// Reset the adapter to initial state
    func reset() async
    
    /// Clean up resources
    func deallocate() async
    
    /// Current state of the adapter
    var isConfigured: Bool { get }
}
