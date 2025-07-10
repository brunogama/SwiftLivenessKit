import UIKit

// MARK: - Mock Adapter for Testing

public actor MockLivenessAdapter: LivenessVendorAdapter {
    private var _isConfigured: Bool = false
    private var currentTask: Task<Void, Never>?
    private var configuration: MockConfiguration?
    
    public typealias Configuration = MockConfiguration
    
    public func configure(with configuration: MockConfiguration) async throws {
        self.configuration = configuration
        setConfigured(true)
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
                        metadata: ["test": .bool(true)]
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
        cancelCurrentTask()
    }
    
    public func deallocate() async {
        await reset()
        configuration = nil
        setConfigured(false)
    }
}

extension MockLivenessAdapter {
    
    public var isConfigured: Bool {
        _isConfigured
    }
    
    public func setConfigured(_ value: Bool) {
        _isConfigured = value
    }
    
    public func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    public func setCurrentTask(_ task: Task<Void, Never>) {
        cancelCurrentTask()
        currentTask = task
    }
}
