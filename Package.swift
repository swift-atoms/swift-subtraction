// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-subtraction",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Subtraction", targets: ["Subtraction"]),

        .library(name: "Subtraction Foundation Integration", targets: ["Subtraction Foundation Integration"]),
        .library(name: "Subtraction Test Support", targets: ["Subtraction Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-addition.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-polarity.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Subtraction",
            dependencies: [
                .product(name: "Addition", package: "swift-addition"),
                .product(name: "Polarity", package: "swift-polarity"),
            ],
            path: "Sources/Subtraction"
        ),
        
        .target(
            name: "Subtraction Foundation Integration",
            dependencies: [
                .target(name: "Subtraction"),
            ],
            path: "Sources/Subtraction Foundation Integration"
        ),
        .target(
            name: "Subtraction Test Support",
            dependencies: [
                .target(name: "Subtraction"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Subtraction Tests",
            dependencies: [
                .target(name: "Subtraction"),
                .product(name: "Polarity", package: "swift-polarity"),
                .target(name: "Subtraction Test Support"),
                .target(name: "Subtraction Foundation Integration"),
            ],
            path: "Tests/Subtraction Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
