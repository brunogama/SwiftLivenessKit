# Changelog

All notable changes to the Swift Liveness Detection Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-01-10

### 🧹 Major Refactoring & Cleanup

#### Code Architecture Improvements
- **Removed entire redundant directory structure** (`Sources/SwiftLivenessKit/` with 7 subdirectories and 20+ files)
- **Eliminated ~90% of code duplication** by removing unused parallel implementations
- **Fixed type definition organization** - moved `SendableSettingsValue` to core types for proper separation of concerns
- **Fixed CompositeLivenessAdapter** - changed from incorrect dictionary structure to proper array-based vendor queue
- **Simplified test structure** - removed redundant test directory (`Tests/SwiftLivenessKitTests/`)

#### Architectural Fixes
- **Single source of truth** - all functionality now lives in `Sources/LivenessDetection/` only
- **Proper dependency management** - core types no longer depend on vendor implementations
- **Consistent package structure** - aligned with `Package.swift` configuration
- **Improved maintainability** - cleaner separation of concerns throughout

#### Files Removed
- All duplicate implementations in `Sources/SwiftLivenessKit/`
- Redundant adapter implementations (MockAdapter, VendorAAdapter, VendorBAdapter duplicates)
- Duplicate composite pattern implementations
- Unused security manager duplicates
- Orphaned test files

### Benefits
- **Dramatically simplified project structure**
- **Eliminated maintenance burden of duplicate code**
- **Fixed architectural inconsistencies**
- **Improved build reliability**
- **Cleaner development experience**

### Breaking Changes
- None (all public APIs remain unchanged)

### Migration Guide
No migration needed - all public APIs are preserved in the clean architecture.

## [1.0.0] - 2024-01-10

### 🎉 Initial Release

#### Core Architecture
- **Actor-based vendor adapters** ensuring thread safety with Swift 6 strict concurrency
- **AsyncThrowingStream** for reactive event propagation
- **Composite adapter pattern** with automatic vendor fallback queue management
- **Protocol-oriented design** following SOLID principles
- **Dependency injection** support with configurable environments
- **Memory-safe implementation** with weak view controller references

#### Vendor Support
- **Multi-vendor architecture** supporting unlimited liveness vendors
- **VendorA adapter** implementation with progress tracking
- **VendorB adapter** implementation with detailed metadata
- **Mock adapter** for testing and development
- **Automatic fallback** when vendors fail or timeout
- **Configurable vendor queue** with priority ordering

#### Security Features
- **App Attest integration** for device integrity verification (iOS 14+)
- **Certificate pinning** for network security
- **Jailbreak detection** with multiple verification methods
- **Biometric data encryption** using CryptoKit
- **Secure credential storage** with Keychain integration

#### Event System
- `LivenessEvent.started` - Detection initiated
- `LivenessEvent.progress(percentage:)` - Progress updates
- `LivenessEvent.instructionChanged(_:)` - User instruction updates
- `LivenessEvent.completed(_:)` - Successful completion with results
- `LivenessEvent.failed(_:)` - Failure with detailed error

#### Error Handling
- **Unified `LivenessError` enum** with comprehensive error cases:
  - `configurationFailed(reason:)` - Configuration issues
  - `timeout(vendor:)` - Vendor-specific timeouts
  - `vendorSpecific(vendor:code:message:)` - Vendor errors
  - `noAvailableVendor` - All vendors exhausted
  - `cancelled` - User or system cancellation
  - `invalidState(_:)` - Invalid adapter state
  - `viewControllerDeallocated` - View controller released

#### UI Integration
- **UIKit support** with example view controller
- **SwiftUI support** with `@MainActor` view model
- **Progress tracking** with real-time updates
- **Instruction display** for user guidance
- **Error presentation** with user-friendly messages

#### Testing Infrastructure
- **Comprehensive unit tests** for all adapters
- **Async test utilities** for stream validation
- **Mock implementations** for UI testing
- **Memory leak tests** with weak reference validation
- **Timeout scenario tests**
- **Security feature tests**

#### Performance Optimizations
- **Lazy adapter initialization**
- **Efficient task cancellation**
- **Minimal memory footprint** (~5MB per session)
- **Sub-10ms assertion generation**
- **Concurrent vendor processing**

#### Developer Experience
- **Extensive documentation** with code examples
- **Best practices guide**
- **Security setup guide**
- **Certificate pinning tutorial** with OpenSSL commands
- **SwiftUI and UIKit examples**
- **Troubleshooting guide**
- **Quick reference cards**

#### Configuration
- **Info.plist templates** for permissions and security
- **Entitlements configuration** for App Attest
- **Certificate pinning setup** instructions
- **Keychain integration** examples

### Breaking Changes
- None (initial release)

### Known Issues
- App Attest not available on simulators (Apple limitation)
- Certificate pinning requires manual certificate extraction
- Jailbreak detection may have false positives on some devices

### Migration Guide
Not applicable (initial release)

## [Unreleased]

### Planned Features
- [ ] Android support via Kotlin Multiplatform
- [ ] Additional vendor adapters (AWS Rekognition, Azure Face API)
- [ ] WebRTC support for real-time video streaming
- [ ] Machine learning model integration for on-device liveness
- [ ] Analytics and monitoring dashboard
- [ ] A/B testing framework for vendor selection
- [ ] Automated certificate rotation
- [ ] Biometric template storage
- [ ] Session recording and playback for debugging
- [ ] Custom vendor SDK integration guide

### Under Consideration
- React Native bridge
- Flutter plugin
- Server-side validation SDK
- Fraud detection integration
- Age estimation support
- Document verification combo