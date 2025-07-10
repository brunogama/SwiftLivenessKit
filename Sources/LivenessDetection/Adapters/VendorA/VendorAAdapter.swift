import UIKit

// MARK: - Vendor A Adapter

public actor VendorAAdapter: BaseLivenessAdapter, LivenessVendorAdapter {
    public typealias Configuration = VendorAConfiguration
    
    private var configuration: VendorAConfiguration?
    private weak var hostingViewController: UIViewController?
    
    public func configure(with configuration: VendorAConfiguration) async throws {
        // Simulate vendor SDK initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Validate API key
        guard !configuration.apiKey.isEmpty else {
            throw LivenessError.configurationFailed(reason: "Invalid API key")
        }
        
        self.configuration = configuration
        await setConfigured(true)
    }
    
    public func startLivenessCheck(
        in viewController: UIViewController
    ) async throws -> AsyncThrowingStream<LivenessEvent, Error> {
        guard await isConfigured else {
            throw LivenessError.invalidState("Adapter not configured")
        }
        
        self.hostingViewController = viewController