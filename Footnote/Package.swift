// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Footnote",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .executable(name: "Footnote", targets: ["Footnote"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.3.0"),
        .package(url: "https://github.com/nmdias/FeedKit", from: "9.0.0")
    ],
    targets: [
        .target(
            name: "Footnote",
            dependencies: ["Publish", "FeedKit"]
        )
    ]
)
