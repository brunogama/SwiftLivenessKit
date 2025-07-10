import Foundation

public struct MockConfiguration: LivenessConfiguration {
    public let vendorName = "Mock"
    public let timeout: TimeInterval
    public let additionalSettings: [String: Any]
    public let shouldSucceed: Bool
    public let simulatedDelay: TimeInterval
    
    public init(
        shouldSucceed: Bool = true,
        simulatedDelay: TimeInterval = 2.0,
        timeout: TimeInterval = 10.0
    ) {
        self.shouldSucceed = shouldSucceed
        self.simulatedDelay = simulatedDelay
        self.timeout = timeout
        self.additionalSettings = [:]
    }
}