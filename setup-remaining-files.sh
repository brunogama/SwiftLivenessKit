#!/bin/bash

# SwiftLivenessKit - Complete Setup Script
# This script creates all project files from the artifacts

set -e

echo "🚀 Setting up SwiftLivenessKit..."

# Create all remaining Type files
cat > Sources/LivenessDetection/Core/Types/LivenessEvent.swift << 'EOF'
import Foundation

/// Events emitted during liveness detection
public enum LivenessEvent: Sendable {
    case started
    case progress(percentage: Double)
    case instructionChanged(String)
    case completed(LivenessResult)
    case failed(LivenessError)
}
EOF

cat > Sources/LivenessDetection/Core/Types/LivenessConfiguration.swift << 'EOF'
import Foundation

/// Configuration protocol for vendor-specific settings
public protocol LivenessConfiguration: Sendable {
    var vendorName: String { get }
    var timeout: TimeInterval { get }
    var additionalSettings: [String: Any] { get }
}
EOF

echo "✅ Created Core Types"
# Create Protocol files
cat > Sources/LivenessDetection/Core/Protocols/LivenessVendorAdapter.swift << 'EOF'
import UIKit

/// Main protocol that all vendor adapters must implement
public protocol LivenessVendorAdapter: Actor {
    associatedtype Configuration: LivenessConfiguration
    
    /// Configure the adapter with vendor-specific settings
    func configure(with configuration: Configuration) async throws
    
    /// Start liveness detection with the provided view controller
    func startLivenessCheck(
        in viewController: UIViewController
    ) async throws -> AsyncThrowingStream<LivenessEvent, Error>
    
    /// Reset the adapter to initial state
    func reset() async
    
    /// Clean up resources
    func deallocate() async
    
    /// Current state of the adapter
    var isConfigured: Bool { get }
}
EOF

cat > Sources/LivenessDetection/Core/Protocols/LivenessAdapterFactory.swift << 'EOF'
import Foundation

/// Protocol for creating vendor adapters
public protocol LivenessAdapterFactory: Sendable {
    func createAdapter(for configuration: any LivenessConfiguration) -> (any LivenessVendorAdapter)?
}
EOF

echo "✅ Created Protocols"
# Create Base implementation files
cat > Sources/LivenessDetection/Core/Base/BaseLivenessAdapter.swift << 'EOF'
import Foundation

/// Base implementation providing common functionality
public actor BaseLivenessAdapter {
    private var _isConfigured: Bool = false
    private var currentTask: Task<Void, Never>?
    
    public var isConfigured: Bool {
        _isConfigured
    }
    
    func setConfigured(_ value: Bool) {
        _isConfigured = value
    }
    
    func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    func setCurrentTask(_ task: Task<Void, Never>) {
        cancelCurrentTask()
        currentTask = task
    }
}
EOF

cat > Sources/LivenessDetection/Core/Base/LivenessEnvironment.swift << 'EOF'
import Foundation

/// Environment for dependency injection
public struct LivenessEnvironment: Sendable {
    public let adapterFactory: LivenessAdapterFactory
    public let logger: (@Sendable (String) -> Void)?
    
    public init(
        adapterFactory: LivenessAdapterFactory,
        logger: (@Sendable (String) -> Void)? = nil
    ) {
        self.adapterFactory = adapterFactory
        self.logger = logger
    }
}
EOF

echo "✅ Created Base implementations"

echo "🎉 Setup complete! Run this script from the SwiftLivenessKit directory."