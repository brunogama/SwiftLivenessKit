import UIKit

// MARK: - Vendor B Adapter

public actor VendorBAdapter: LivenessVendorAdapter {
    private var configuration: VendorBConfiguration?
    private weak var hostingViewController: UIViewController?
    private var vendorSDKHandle: Any? // Simulated vendor SDK handle
    
    // MARK: - Configuration State
    private var _isConfigured: Bool = false
    public var isConfigured: Bool { _isConfigured }
    
    private func setConfigured(_ value: Bool) {
        _isConfigured = value
    }
    
    // MARK: - Lifecycle
    public func configure(with configuration: VendorBConfiguration) async throws {
        // Simulate more complex vendor initialization
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Validate credentials
        guard !configuration.clientId.isEmpty && !configuration.clientSecret.isEmpty else {
            throw LivenessError.configurationFailed(reason: "Invalid credentials")
        }
        
        // Simulate SDK initialization that might fail
        let shouldFail = Int.random(in: 0...9) == 0 // 10% chance of failure
        if shouldFail {
            throw LivenessError.configurationFailed(reason: "Network connectivity issue")
        }
        
        self.configuration = configuration
        self.vendorSDKHandle = "SDK_Handle_\(UUID().uuidString)"
        setConfigured(true)
    }
    
    public func startLivenessCheck(
        in viewController: UIViewController
    ) async throws -> AsyncThrowingStream<LivenessEvent, Error> {
        guard isConfigured else {
            throw LivenessError.invalidState("Adapter not configured")
        }
        
        self.hostingViewController = viewController
        
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    continuation.yield(.started)
                    
                    // VendorB has different progress steps
                    let steps: [(Double, String)] = [
                        (0.2, "Center your face in the frame"),
                        (0.4, "Move closer to the camera"),
                        (0.6, "Blink twice"),
                        (0.8, "Turn your head slowly"),
                        (1.0, "Processing...")
                    ]
                    
                    for (progress, instruction) in steps {
                        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second per step
                        
                        if Task.isCancelled {
                            throw LivenessError.cancelled
                        }
                        
                        // Ensure the hosting view controller is still present
                        if self.hostingViewController == nil {
                            throw LivenessError.viewControllerDeallocated
                        }
                        
                        continuation.yield(.progress(percentage: progress))
                        continuation.yield(.instructionChanged(instruction))
                    }
                    
                    // Provide a simulated result
                    let result = LivenessResult(
                        vendor: "VendorB",
                        confidence: 0.98,
                        metadata: [
                            "sessionId": .string(UUID().uuidString),
                            "faceQuality": .double(0.92),
                            "livenessScore": .double(0.99),
                            "processingTime": .double(5.2)
                        ]
                    )
                    
                    continuation.yield(.completed(result))
                    continuation.finish()
                } catch {
                    continuation.yield(.failed(error as? LivenessError ?? .vendorSpecific(
                        vendor: "VendorB",
                        code: -2,
                        message: error.localizedDescription
                    )))
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    public func reset() async {
        self.hostingViewController = nil
        self.vendorSDKHandle = nil
        self.configuration = nil
        setConfigured(false)
    }
    
    public func deallocate() async {
        await reset()
    }
} 

