import Foundation
import UIKit

// MARK: - Composite Adapter

/// Manages multiple vendor adapters with automatic fallback
public actor CompositeLivenessAdapter {
    private let environment: LivenessEnvironment
    private var vendorQueue: [SendableSettingsValue: LivenessConfiguration]
    private var currentAdapterIndex: Int = 0
    private weak var hostingViewController: UIViewController?
    
    public init(
        environment: LivenessEnvironment,
        vendorConfigurations: [SendableSettingsValue: LivenessConfiguration]
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
        let vendorConfigurations = Array(vendorQueue.values)
        
        while currentAdapterIndex < vendorConfigurations.count {
            let configuration = vendorConfigurations[currentAdapterIndex]
            
            log("Attempting vendor: \(configuration.vendorName)")
            
            // Create adapter for current vendor
            guard let adapter = environment.adapterFactory.createAdapter(for: configuration) else {
                log("Failed to create adapter for \(configuration.vendorName)")
                currentAdapterIndex += 1
                continue
            }
            
            // Configure with timeout using a generic helper
            do {
                try await withTimeout(seconds: 5) {
                    try await adapter.configureAny(configuration)
                }
            } catch {
                log("Configuration failed for \(configuration.vendorName): \(error)")
                currentAdapterIndex += 1
                continue
            }
            
            log("Successfully configure \(configuration.vendorName)")
            
            // Check if view controller is still valid
            guard let _ = hostingViewController else {
                continuation.finish(throwing: LivenessError.viewControllerDeallocated)
                return
            }
            
            // If we reach here, presumably more code would continue the process,
            // but since not provided, we just break out of the loop
            
            break
        }
    }
    
    private func log(_ message: String) {
        environment.logger?("[CompositeLivenessAdapter] \(message)")
    }
}

// MARK: - Type‑erased adapter utilities

private extension LivenessVendorAdapter {
    /// Allows configuring `any LivenessVendorAdapter` values by erasing the
    /// associated‑type requirement at the call‑site.  A runtime check guarantees
    /// the concrete adapter receives a matching configuration.
    func configureAny(_ configuration: LivenessConfiguration) async throws {
        guard let typedConfig = configuration as? Configuration else {
            throw LivenessError.invalidState(
                "Configuration type mismatch. Expected \(Configuration.self), got \(type(of: configuration))"
            )
        }
        try await configure(with: typedConfig)
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
