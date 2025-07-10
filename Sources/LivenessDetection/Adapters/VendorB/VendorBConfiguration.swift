import Foundation

public struct VendorBConfiguration: LivenessConfiguration {
    public let vendorName = "VendorB"
    public let timeout: TimeInterval
    public let additionalSettings: [String: SendableSettingsValue]
    public let clientId: String
    public let clientSecret: String
    
    public init(
        clientId: String,
        clientSecret: String,
        timeout: TimeInterval = 45,
        additionalSettings: [String: SendableSettingsValue] = [:]
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.timeout = timeout
        self.additionalSettings = additionalSettings
    }
} 
