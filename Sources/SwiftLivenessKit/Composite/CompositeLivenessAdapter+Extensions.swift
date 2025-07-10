import Foundation

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
