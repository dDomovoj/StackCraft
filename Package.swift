// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "StackCraft",
  platforms: [SupportedPlatform.iOS(.v11)],
  products: [.library(name: "StackCraft", targets: ["StackCraft"])],
  dependencies: [],
  targets: [.target(name: "StackCraft", dependencies: [], path: "Sources/StackCraft")],
  swiftLanguageVersions: [.v5]
)
