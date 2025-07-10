import Foundation

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
