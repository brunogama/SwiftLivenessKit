import Foundation

// MARK: - Vendor Configuration Examples

public struct VendorAConfiguration: LivenessConfiguration {
    public let vendorName = "VendorA"
    public let timeout: TimeInterval
    public let additionalSettings: [String: Any]
    public let apiKey: String
    
    public init(apiKey: String, timeout: TimeInterval = 30, additionalSettings: [String: Any] = [:]) {
        self.apiKey = apiKey
        self.timeout = timeout
        self.additionalSettings = additionalSettings
    }
}

public struct VendorBConfiguration: LivenessConfiguration {
    public let vendorName = "VendorB"
    public let timeout: TimeInterval
    public let additionalSettings: [String: Any]
    public let clientId: String
    public let clientSecret: String
    
    public init(
        clientId: String,
        clientSecret: String,
        timeout: TimeInterval = 45,
        additionalSettings: [String: Any] = [:]
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.timeout = timeout
        self.additionalSettings = additionalSettings
    }
}
