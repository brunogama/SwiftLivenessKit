import UIKit

// MARK: - Composite Adapter

/// Manages multiple vendor adapters with automatic fallback
public actor CompositeLivenessAdapter {
    private let environment: LivenessEnvironment
    private var vendorQueue: [any LivenessConfiguration]
    private var currentAdapterIndex: Int = 0
    private var adapters: [any LivenessVendorAdapter] = []
    private weak var hostingViewController: UIViewController?
    
    public init(
        environment: LivenessEnvironment,
        vendorConfigurations: [any LivenessConfiguration]
    ) {
        self.environment = environment
        self.vendorQueue = vendorConfigurations
    }
    
    /// Start liveness detection with automatic vendor fallback
    public func startLivenessDetection(
        in viewController: UIViewController
    ) -> AsyncThrowingStream<LivenessEvent, Error> {
        self.hostingViewController = viewController
        
        return AsyncThrowingStream { continuation in
            let task = Task {
                await self.processVendorQueue(continuation: continuation)
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }    
    private func processVendorQueue(
        continuation: AsyncThrowingStream<LivenessEvent, Error>.Continuation
    ) async {
        currentAdapterIndex = 0
        
        while currentAdapterIndex < vendorQueue.count {
            let configuration = vendorQueue[currentAdapterIndex]
            
            log("Attempting vendor: \(configuration.vendorName)")
            
            do {
                // Create adapter for current vendor
                guard let adapter = environment.adapterFactory.createAdapter(for: configuration) else {
                    log("Failed to create adapter for \(configuration.vendorName)")
                    currentAdapterIndex += 1
                    continue
                }
                
                adapters.append(adapter)
                
                // Configure with timeout
                try await withTimeout(seconds: 5) {
                    try await adapter.configure(with: configuration)
                }
                
                log("Successfully configured \(configuration.vendorName)")
                
                // Check if view controller is still valid
                guard let viewController = hostingViewController else {
                    throw LivenessError.viewControllerDeallocated
                }