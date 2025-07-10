import Foundation

// MARK: - Adapter Factory Implementation

public struct DefaultAdapterFactory: LivenessAdapterFactory {
    public init() {}
    
    public func createAdapter(for configuration: any LivenessConfiguration) -> (any LivenessVendorAdapter)? {
        switch configuration.vendorName {
        case "VendorA":
            return VendorAAdapter()
        case "VendorB":
            return VendorBAdapter()
        case "Mock":
            return MockLivenessAdapter()
        default:
            return nil
        }
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
