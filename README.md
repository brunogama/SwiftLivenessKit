# SwiftLivenessKit

A production-ready, multi-vendor liveness detection system built with Swift 6's strict concurrency, featuring automatic vendor fallback, comprehensive security, and reactive event streams.

## Features

✅ **Clean Architecture** - Single source of truth with no code duplication  
✅ **Multi-Vendor Support** - Automatic fallback between liveness detection vendors  
✅ **Swift 6 Concurrency** - Actor-based design with strict concurrency safety  
✅ **Reactive Events** - AsyncThrowingStream for real-time progress updates  
✅ **Type Safety** - Comprehensive error handling and strongly-typed configurations  
✅ **Memory Safe** - Weak references and automatic cleanup  
✅ **iOS 14+ Support** - Compatible with modern iOS deployment targets  

## Project Structure

```
SwiftLivenessKit/
├── Package.swift                 # Swift Package Manager configuration
├── Sources/
│   └── LivenessDetection/       # Main library module
│       ├── Core/
│       │   ├── Types/           # Core data types (Result, Error, Event, Configuration)
│       │   ├── Protocols/       # Main protocol definitions
│       │   ├── Base/            # Base implementations
│       │   └── Composite/       # Composite adapter for vendor management
│       ├── Adapters/
│       │   ├── VendorA/         # VendorA implementation
│       │   ├── VendorB/         # VendorB implementation
│       │   └── Mock/            # Mock adapter for testing
│       ├── Security/            # Security features
│       └── Factory/             # Adapter factory
└── Tests/
    └── LivenessDetectionTests/  # Unit tests
```

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftLivenessKit.git", from: "1.0.1")
]
```

Or in Xcode:
1. Go to File → Add Package Dependencies
2. Enter the repository URL
3. Select version 1.0.1 or later

## Quick Start

```swift
import LivenessDetection

// Configure vendors
let vendorConfigs: [any LivenessConfiguration] = [
    VendorAConfiguration(apiKey: "your-api-key"),
    VendorBConfiguration(clientId: "your-client-id", clientSecret: "your-client-secret"),
    MockConfiguration(shouldSucceed: true) // For testing
]

// Create adapter factory and environment
let factory = DefaultAdapterFactory()
let environment = LivenessEnvironment(
    adapterFactory: factory,
    logger: { print("LivenessKit: \($0)") }
)

// Create composite adapter
let adapter = CompositeLivenessAdapter(
    environment: environment,
    vendorConfigurations: vendorConfigs
)

// Perform liveness detection
let eventStream = adapter.startLivenessDetection(in: viewController)

for try await event in eventStream {
    switch event {
    case .started:
        print("Liveness detection started")
    case .progress(let percentage):
        print("Progress: \(percentage * 100)%")
    case .instructionChanged(let instruction):
        print("Instruction: \(instruction)")
    case .completed(let result):
        print("Success! Confidence: \(result.confidence)")
        break
    case .failed(let error):
        print("Error: \(error.localizedDescription)")
        break
    }
}
```

## Architecture

### Core Components

- **LivenessVendorAdapter** - Protocol for vendor-specific implementations
- **CompositeLivenessAdapter** - Manages multiple vendors with automatic fallback
- **LivenessConfiguration** - Type-safe configuration for each vendor
- **LivenessEvent** - Reactive event system for progress tracking
- **LivenessError** - Comprehensive error handling

### Vendor Support

The framework supports multiple liveness detection vendors:

- **VendorA** - Fast detection with basic progress tracking
- **VendorB** - Detailed metadata and comprehensive progress steps
- **Mock** - For testing and development

### Event System

```swift
public enum LivenessEvent {
    case started
    case progress(percentage: Double)
    case instructionChanged(String)
    case completed(LivenessResult)
    case failed(LivenessError)
}
```

### Error Handling

```swift
public enum LivenessError: Error {
    case configurationFailed(reason: String)
    case timeout(vendor: String)
    case vendorSpecific(vendor: String, code: Int, message: String)
    case noAvailableVendor
    case cancelled
    case invalidState(String)
    case viewControllerDeallocated
}
```

## Requirements

- iOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Version History

- **1.0.1** - Major refactoring and cleanup (2025-01-10)
- **1.0.0** - Initial release (2024-01-10)

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

For issues and questions, please open an issue on GitHub or contact the maintainers.