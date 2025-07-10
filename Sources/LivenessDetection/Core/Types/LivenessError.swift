import Foundation

/// Unified error type for all liveness detection failures
public enum LivenessError: Error, Equatable {
    case configurationFailed(reason: String)
    case timeout(vendor: String)
    case vendorSpecific(vendor: String, code: Int, message: String)
    case noAvailableVendor
    case cancelled
    case invalidState(String)
    case viewControllerDeallocated
}

extension LivenessError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .configurationFailed(let reason):
            return "Configuration failed: \(reason)"
        case .timeout(let vendor):
            return "Timeout occurred for vendor: \(vendor)"
        case .vendorSpecific(let vendor, let code, let message):
            return "Vendor \(vendor) error (\(code)): \(message)"
        case .noAvailableVendor:
            return "No available vendor for liveness detection"
        case .cancelled:
            return "Liveness detection was cancelled"
        case .invalidState(let state):
            return "Invalid state: \(state)"
        case .viewControllerDeallocated:
            return "View controller was deallocated during liveness check"
        }
    }
}