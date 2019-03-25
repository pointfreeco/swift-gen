// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Gen",
  products: [
    .library(name: "Gen", targets: ["Gen"])
  ],
  dependencies: [
    .package(url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.3.0"),
  ],
  targets: [
    .target(name: "Gen", dependencies: []),
    .testTarget(name: "GenTests", dependencies: ["Gen"]),
  ]
)
