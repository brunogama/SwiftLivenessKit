import UIKit

// MARK: - Vendor A Adapter

public actor VendorAAdapter: BaseLivenessAdapter, LivenessVendorAdapter {
    public typealias Configuration = VendorAConfiguration
    
    private var configuration: VendorAConfiguration?
    private weak var hostingViewController: UIViewController?
    
    public func configure(with configuration: VendorAConfiguration) async throws {
        // Simulate vendor SDK initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Validate API key
        guard !configuration.apiKey.isEmpty else {
            throw LivenessError.configurationFailed(reason: "Invalid API key")
        }
        
        self.configuration = configuration
        await setConfigured(true)
    }
    
    public func startLivenessCheck(
        in viewController: UIViewController
    ) async throws -> AsyncThrowingStream<LivenessEvent, Error> {
        guard await isConfigured else {
            throw LivenessError.invalidState("Adapter not configured")
        }
        
        self.hostingViewController = viewController
        
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    // Send start event
                    continuation.yield(.started)
                    
                    // Simulate liveness detection process
                    for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
                        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        
                        if Task.isCancelled {
                            throw LivenessError.cancelled
                        }
                        
                        // Check if view controller is still alive
                        if await self.hostingViewController == nil {
                            throw LivenessError.viewControllerDeallocated
                        }
                        
                        continuation.yield(.progress(percentage: progress))
                        
                        if progress == 0.3 {
                            continuation.yield(.instructionChanged("Please turn your head left"))
                        } else if progress == 0.6 {
                            continuation.yield(.instructionChanged("Please turn your head right"))
                        } else if progress == 0.9 {
                            continuation.yield(.instructionChanged("Please smile"))
                        }
                    }
                    
                    // Create success result
                    let result = LivenessResult(
                        vendor: "VendorA",
                        confidence: 0.95,
                        metadata: ["sessionId": UUID().uuidString]
                    )
                    
                    continuation.yield(.completed(result))
                    continuation.finish()
                    
                } catch {
                    continuation.yield(.failed(error as? LivenessError ?? .vendorSpecific(
                        vendor: "VendorA",
                        code: -1,
                        message: error.localizedDescription
                    )))
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
            
            Task {
                await self.setCurrentTask(task)
            }
        }
    }
    
    public func reset() async {
        await cancelCurrentTask()
        hostingViewController = nil
    }
    
    public func deallocate() async {
        await reset()
        configuration = nil
        await setConfigured(false)
    }
}
