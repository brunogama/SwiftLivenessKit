// SwiftLivenessKit
// A modern Swift package for multi-vendor liveness detection

// MARK: - Core Types
@_exported import struct SwiftLivenessKit.LivenessResult
@_exported import enum SwiftLivenessKit.LivenessError
@_exported import enum SwiftLivenessKit.LivenessEvent

// MARK: - Protocols
@_exported import protocol SwiftLivenessKit.LivenessConfiguration
@_exported import protocol SwiftLivenessKit.LivenessVendorAdapter
@_exported import protocol SwiftLivenessKit.LivenessAdapterFactory

// MARK: - Base Implementation
@_exported import actor SwiftLivenessKit.BaseLivenessAdapter

// MARK: - Dependency Injection
@_exported import struct SwiftLivenessKit.LivenessEnvironment
@_exported import struct SwiftLivenessKit.DefaultAdapterFactory

// MARK: - Configurations
@_exported import struct SwiftLivenessKit.VendorAConfiguration
@_exported import struct SwiftLivenessKit.VendorBConfiguration

// MARK: - Adapters
@_exported import actor SwiftLivenessKit.VendorAAdapter
@_exported import actor SwiftLivenessKit.MockLivenessAdapter

// MARK: - Composite
@_exported import actor SwiftLivenessKit.CompositeLivenessAdapter