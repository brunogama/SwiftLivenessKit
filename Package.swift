// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftLivenessKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "LivenessDetection",
            targets: ["LivenessDetection"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LivenessDetection",
            dependencies: [],
            path: "Sources/LivenessDetection"
        ),
        .testTarget(
            name: "LivenessDetectionTests",
            dependencies: ["LivenessDetection"],
            path: "Tests/LivenessDetectionTests"
        ),
    ]
)