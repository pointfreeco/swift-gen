// swift-tools-version:5.0
import Foundation
import PackageDescription

let package = Package(
  name: "Gen",
  products: [
    .library(name: "Gen", targets: ["Gen"])
  ],
  targets: [
    .target(name: "Gen", dependencies: []),
    .testTarget(name: "GenTests", dependencies: ["Gen"]),
  ]
)

if ProcessInfo.processInfo.environment.keys.contains("PF_DEVELOP") {
  package.dependencies.append(
    contentsOf: [
      .package(url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.3.0"),
    ]
  )
}
