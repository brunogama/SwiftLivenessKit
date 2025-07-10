import Foundation

public struct VendorAConfiguration: LivenessConfiguration {
    public let vendorName = "VendorA"
    public let timeout: TimeInterval
    public let additionalSettings: [String: SendableSettingsValue]
    public let apiKey: String
    
    public init(apiKey: String, timeout: TimeInterval = 30, additionalSettings: [String: SendableSettingsValue] = [:]) {
        self.apiKey = apiKey
        self.timeout = timeout
        self.additionalSettings = additionalSettings
    }
}

