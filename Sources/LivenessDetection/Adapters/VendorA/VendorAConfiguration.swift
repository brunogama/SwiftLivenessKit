import Foundation

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