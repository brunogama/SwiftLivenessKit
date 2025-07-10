import Foundation

/// Events emitted during liveness detection
public enum LivenessEvent: Sendable {
    case started
    case progress(percentage: Double)
    case instructionChanged(String)
    case completed(LivenessResult)
    case failed(LivenessError)
}

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
