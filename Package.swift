// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "nightshift",
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.7.0"),
  ],
  targets: [
    .target(
      name: "DisplayClient",
      path: "Sources/ObjC/DisplayClient",
      linkerSettings: [
        .unsafeFlags(["-F/System/Library/PrivateFrameworks"]),
        .linkedFramework("CoreBrightness"),
      ]
    ),
    .executableTarget(
      name: "nightshift",
      dependencies: [
        .byName(name: "DisplayClient"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      path: "Sources/Swift"
    ),
  ]
)
