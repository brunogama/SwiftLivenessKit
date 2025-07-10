import Foundation

// MARK: - Async Helpers

/// Execute an async operation with a timeout
func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw LivenessError.timeout(vendor: "Operation")
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}