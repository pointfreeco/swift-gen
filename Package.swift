// swift-tools-version:5.5
import Foundation
import PackageDescription

let package = Package(
  name: "swift-gen",
  products: [
    .library(name: "Gen", targets: ["Gen"])
  ],
  targets: [
    .target(name: "Gen", dependencies: []),
    .testTarget(name: "GenTests", dependencies: ["Gen"]),
  ]
)
