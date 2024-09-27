// swift-tools-version:5.9
import Foundation
import PackageDescription

let package = Package(
  name: "swift-gen",
  products: [
    .library(name: "Gen", targets: ["Gen"])
  ],
  targets: [
    .target(
      name: "Gen",
      dependencies: [],
      swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
    ),
    .testTarget(name: "GenTests", dependencies: ["Gen"]),
  ]
)
