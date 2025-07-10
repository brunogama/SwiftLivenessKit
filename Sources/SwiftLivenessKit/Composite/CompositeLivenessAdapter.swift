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
                
                // Start liveness check with vendor timeout
                let stream = try await adapter.startLivenessCheck(in: viewController)
                
                // Process events from vendor
                let success = await processVendorStream(
                    stream: stream,
                    vendorName: configuration.vendorName,
                    timeout: configuration.timeout,
                    continuation: continuation
                )
                
                if success {
                    // Success - we're done
                    continuation.finish()
                    return
                }
                
            } catch {
                log("Vendor \(configuration.vendorName) failed: \(error)")
                
                // Notify about vendor failure
                continuation.yield(.failed(LivenessError.vendorSpecific(
                    vendor: configuration.vendorName,
                    code: -1,
                    message: "Vendor failed: \(error.localizedDescription)"
                )))
            }
            
            // Move to next vendor
            currentAdapterIndex += 1
            
            // Small delay before trying next vendor
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        // All vendors failed
        continuation.yield(.failed(LivenessError.noAvailableVendor))
        continuation.finish(throwing: LivenessError.noAvailableVendor)
    }
    
    private func processVendorStream(
        stream: AsyncThrowingStream<LivenessEvent, Error>,
        vendorName: String,
        timeout: TimeInterval,
        continuation: AsyncThrowingStream<LivenessEvent, Error>.Continuation
    ) async -> Bool {
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            return false
        }
        
        let streamTask = Task {
            do {
                for try await event in stream {
                    // Forward events to main continuation
                    continuation.yield(event)
                    
                    // Check for completion
                    if case .completed = event {
                        return true
                    }
                }
                return false
            } catch {
                log("Stream error for \(vendorName): \(error)")
                return false
            }
        }
        
        // Race between timeout and stream completion
        let result = await withTaskGroup(of: Bool.self) { group in
            group.addTask { await timeoutTask.value }
            group.addTask { await streamTask.value }
            
            for await value in group {
                group.cancelAll()
                return value
            }
            
            return false
        }
        
        if !result {
            log("Vendor \(vendorName) timed out")
            continuation.yield(.failed(LivenessError.timeout(vendor: vendorName)))
        }
        
        return result
    }
    
    /// Reset all adapters
    public func reset() async {
        for adapter in adapters {
            await adapter.reset()
        }
        currentAdapterIndex = 0
        hostingViewController = nil
    }
    
    /// Clean up all resources
    public func deallocate() async {
        for adapter in adapters {
            await adapter.deallocate()
        }
        adapters.removeAll()
        currentAdapterIndex = 0
        hostingViewController = nil
    }
    
    /// Update vendor queue
    public func updateVendorQueue(_ configurations: [any LivenessConfiguration]) {
        vendorQueue = configurations
        currentAdapterIndex = 0
    }
    
    private func log(_ message: String) {
        environment.logger?("[CompositeLivenessAdapter] \(message)")
    }
}
