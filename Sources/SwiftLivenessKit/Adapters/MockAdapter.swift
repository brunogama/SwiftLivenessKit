import UIKit

// MARK: - Mock Adapter for Testing

public actor MockLivenessAdapter: BaseLivenessAdapter, LivenessVendorAdapter {
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
    
    public typealias Configuration = MockConfiguration
    
    private var configuration: MockConfiguration?
    
    public init() {}
    
    public func configure(with configuration: MockConfiguration) async throws {
        self.configuration = configuration
        await setConfigured(true)
    }    
    public func startLivenessCheck(
        in viewController: UIViewController
    ) async throws -> AsyncThrowingStream<LivenessEvent, Error> {
        guard let config = configuration else {
            throw LivenessError.invalidState("Not configured")
        }
        
        return AsyncThrowingStream { continuation in
            let task = Task {
                continuation.yield(.started)
                
                if config.shouldSucceed {
                    try? await Task.sleep(nanoseconds: UInt64(config.simulatedDelay * 1_000_000_000))
                    
                    let result = LivenessResult(
                        vendor: "Mock",
                        confidence: 1.0,
                        metadata: ["test": true]
                    )
                    continuation.yield(.completed(result))
                } else {
                    continuation.yield(.failed(LivenessError.vendorSpecific(
                        vendor: "Mock",
                        code: 999,
                        message: "Simulated failure"
                    )))
                }
                
                continuation.finish()
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    public func reset() async {
        await cancelCurrentTask()
    }
    
    public func deallocate() async {
        await reset()
        configuration = nil
        await setConfigured(false)
    }
}