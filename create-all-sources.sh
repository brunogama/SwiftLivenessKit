#!/bin/bash

# SwiftLivenessKit - Create All Source Files
# Run this from the SwiftLivenessKit directory

echo "📦 Creating all SwiftLivenessKit source files..."

# Complete the CompositeLivenessAdapter
cat >> Sources/LivenessDetection/Core/Composite/CompositeLivenessAdapter.swift << 'EOF'
                
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

// MARK: - Timeout Helper

private func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw LivenessError.timeout(vendor: "Configuration")
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

// MARK: - Convenience Extensions

extension CompositeLivenessAdapter {
    /// Convenience method to process liveness and get single result
    public func performLivenessCheck(
        in viewController: UIViewController
    ) async throws -> LivenessResult {
        let stream = startLivenessDetection(in: viewController)
        
        for try await event in stream {
            if case .completed(let result) = event {
                return result
            }
        }
        
        throw LivenessError.noAvailableVendor
    }
}
EOF

echo "✅ Completed CompositeLivenessAdapter"