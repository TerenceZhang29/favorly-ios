// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FavorlyKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "FavorlyCore", targets: ["FavorlyCore"]),
        .library(name: "FavorlyData", targets: ["FavorlyData"]),
        .library(name: "FavorlyFeatures", targets: ["FavorlyFeatures"]),
    ],
    targets: [
        .target(name: "FavorlyCore"),
        .target(name: "FavorlyData", dependencies: ["FavorlyCore"]),
        .target(name: "FavorlyFeatures", dependencies: ["FavorlyCore"]),
        .testTarget(name: "FavorlyCoreTests", dependencies: ["FavorlyCore"]),
        .testTarget(name: "FavorlyDataTests", dependencies: ["FavorlyData"]),
        .testTarget(name: "FavorlyFeaturesTests", dependencies: ["FavorlyFeatures"]),
    ]
)
