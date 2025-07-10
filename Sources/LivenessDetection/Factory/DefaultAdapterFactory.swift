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