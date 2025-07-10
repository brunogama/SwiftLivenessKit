# SwiftLivenessKit

A production-ready, multi-vendor liveness detection system built with Swift 6's strict concurrency, featuring automatic vendor fallback, comprehensive security, and reactive event streams.

## Project Structure

```
SwiftLivenessKit/
├── Package.swift                 # Swift Package Manager configuration
├── Sources/
│   └── LivenessDetection/
│       ├── Core/
│       │   ├── Types/           # Core data types (Result, Error, Event, Configuration)
│       │   ├── Protocols/       # Main protocol definitions
│       │   ├── Base/            # Base implementations
│       │   └── Composite/       # Composite adapter for vendor management
│       ├── Adapters/
│       │   ├── VendorA/         # VendorA implementation
│       │   ├── VendorB/         # VendorB implementation
│       │   └── Mock/            # Mock adapter for testing
│       ├── Security/            # Security features (App Attest, etc.)
│       └── Factory/             # Adapter factory
└── Tests/
    └── LivenessDetectionTests/  # Unit tests
```

## Quick Start

1. Open in Xcode:
```bash
cd /Users/bruno/Developer/deep-researchs/sdkadapter/SwiftLivenessKit
open Package.swift
```

2. Basic Usage:
```swift
import LivenessDetection

// Configure vendors
let vendorConfigs: [any LivenessConfiguration] = [
    VendorAConfiguration(apiKey: "your-key"),
    VendorBConfiguration(clientId: "id", clientSecret: "secret")
]

// Create adapter
let factory = DefaultAdapterFactory()
let environment = LivenessEnvironment(
    adapterFactory: factory,
    logger: { print($0) }
)

let adapter = CompositeLivenessAdapter(
    environment: environment,
    vendorConfigurations: vendorConfigs
)

// Perform liveness check
let result = try await adapter.performLivenessCheck(in: viewController)
print("Liveness verified! Confidence: \(result.confidence)")
```

## Files Created

- ✅ Core Types (LivenessError, LivenessResult, LivenessEvent, LivenessConfiguration)
- ✅ Protocols (LivenessVendorAdapter, LivenessAdapterFactory)
- ✅ Base Implementations (BaseLivenessAdapter, LivenessEnvironment)
- ✅ Composite Adapter (started - needs completion)
- 🚧 Vendor Adapters (partially created)
- 🚧 Security Manager (not yet created)
- 🚧 Factory Implementation (not yet created)
- 🚧 Tests (not yet created)

## Next Steps

1. Complete the remaining vendor adapter implementations
2. Add the security manager and App Attest support
3. Create the factory implementation
4. Add comprehensive unit tests
5. Add documentation in the docs/ directory

## Documentation

See the `docs/` directory for:
- Getting Started Tutorial
- API Reference
- Security Guide
- Certificate Pinning Tutorial
- Migration Guide

## License

MIT License - see LICENSE file for details.