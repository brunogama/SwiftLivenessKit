import Foundation

// MARK: - Dependency Injection

/// Protocol for creating vendor adapters
public protocol LivenessAdapterFactory: Sendable {
    func createAdapter(for configuration: any LivenessConfiguration) -> (any LivenessVendorAdapter)?
}

/// Environment for dependency injection
public struct LivenessEnvironment: Sendable {
    public let adapterFactory: LivenessAdapterFactory
    public let logger: (@Sendable (String) -> Void)?
    
    public init(
        adapterFactory: LivenessAdapterFactory,
        logger: (@Sendable (String) -> Void)? = nil
    ) {
        self.adapterFactory = adapterFactory
        self.logger = logger
    }
}

/// Default adapter factory implementation
public struct DefaultAdapterFactory: LivenessAdapterFactory {
    public init() {}
    
    public func createAdapter(for configuration: any LivenessConfiguration) -> (any LivenessVendorAdapter)? {
        // This will be extended by users to add their vendor adapters
        return nil
    }
}