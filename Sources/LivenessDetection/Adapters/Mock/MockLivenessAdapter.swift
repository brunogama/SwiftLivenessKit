import UIKit

// MARK: - Mock Adapter for Testing

public actor MockLivenessAdapter: BaseLivenessAdapter, LivenessVendorAdapter {
    public typealias Configuration = MockConfiguration
    
    private var configuration: MockConfiguration?
    
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