import UIKit

// MARK: - Vendor A Adapter

public actor VendorAAdapter: LivenessVendorAdapter {
    private var configuration: VendorAConfiguration?
    private weak var hostingViewController: UIViewController?
    
    private var _isConfigured: Bool = false
    public var isConfigured: Bool {
        _isConfigured
    }
    
    private func setConfigured(_ value: Bool) {
        _isConfigured = value
    }
    
    public func configure(with configuration: VendorAConfiguration) async throws {
        // Simulate vendor SDK initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Validate API key
        guard !configuration.apiKey.isEmpty else {
            throw LivenessError.configurationFailed(reason: "Invalid API key")
        }
        
        self.configuration = configuration
        setConfigured(true)
    }
    
    public func startLivenessCheck(
        in viewController: UIViewController
    ) async throws -> AsyncThrowingStream<LivenessEvent, Error> {
        guard isConfigured else {
            throw LivenessError.invalidState("Adapter not configured")
        }
        
        self.hostingViewController = viewController
        
        // For now, provide a minimal stub stream.
        return AsyncThrowingStream { continuation in
            continuation.yield(.started)
            continuation.finish()
        }
    }
    
    public func reset() async {
        configuration = nil
        setConfigured(false)
    }
    
    public func deallocate() async {
        configuration = nil
        hostingViewController = nil
        setConfigured(false)
    }
}
