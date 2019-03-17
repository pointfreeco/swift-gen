# 🎱 Gen

[![Swift 4.2](https://img.shields.io/badge/swift-4.2-ED523F.svg?style=flat)](https://swift.org/download/)
[![iOS/macOS/tvOS/watchOS CI](https://img.shields.io/circleci/project/github/pointfreeco/swift-gen/master.svg?label=ios/macos)](https://circleci.com/gh/pointfreeco/swift-gen)
[![Linux CI](https://img.shields.io/travis/pointfreeco/swift-gen/master.svg?label=linux)](https://travis-ci.org/pointfreeco/swift-gen)
[![@pointfreeco](https://img.shields.io/badge/contact-@pointfreeco-5AA9E7.svg?style=flat)](https://twitter.com/pointfreeco)

Composable, transformable, controllable randomness.

## Table of Contents

- [Motivation](#motivation)
- [Examples](#examples)
- [Installation](#installation)
- [Interested in learning more?](#interested-in-learning-more)
- [License](#license)

## Motivation

Swift's randomness API is powerful and simple to use, but static and limited. While it goes beyond random numbers and can generate random booleans, shuffle and pluck random elements from collections, it goes no further and provides no means for extensibility. Gen is a lightweight wrapper over Swift's randomness APIs that makes it easy to build custom generators of any kind of value.

## Examples

Gen's namesake type, `Gen`, is responsible for producing random values.

``` swift
Gen.bool
// Gen<Bool>
```

Every random function that comes with Swift is also available as a function on `Gen`.

``` swift
Int.random(in: 1...10) // 4
Gen.int(in: 1...10) // Gen<Int>
```

Rather than immediately produce a random value, `Gen` describes a random value that can be produced by calling its `run` method.

``` swift
Gen.int(in: 1...10).run() // 2
```

It's precisely this 

Gen's main building block of randomness is the `Gen` type, which is generic over the random values it can generate. `Gen` values 

## Installation

### Carthage

If you use [Carthage](https://github.com/Carthage/Carthage), you can add the following dependency to your `Cartfile`:

``` ruby
github "pointfreeco/swift-gen" ~> 0.1
```

### CocoaPods

If your project uses [CocoaPods](https://cocoapods.org), just add the following to your `Podfile`:

``` ruby
pod 'Gen', '~> 0.1'
```

### SwiftPM

If you want to use Gen in a project that uses [SwiftPM](https://swift.org/package-manager/), it's as simple as adding a `dependencies` clause to your `Package.swift`:

``` swift
dependencies: [
.package(url: "https://github.com/pointfreeco/swift-gen.git", from: "0.1.0")
]
```

### Xcode Sub-project

Submodule, clone, or download Gen, and drag `Gen.xcodeproj` into your project.

## Interested in learning more?

These concepts (and more) are explored thoroughly in [Point-Free](https://www.pointfree.co), a video series exploring functional programming and Swift hosted by [Brandon Williams](https://github.com/mbrandonw) and [Stephen Celis](https://github.com/stephencelis).

The design of this library was explored in the following [Point-Free](https://www.pointfree.co) episodes:

- [Episode 30](https://www.pointfree.co/episodes/ep30-composable-randomness): Composable Randomness
- [Episode 31](https://www.pointfree.co/episodes/ep31-decodable-randomness-part-1): Decodable Randomness: Part 1
- [Episode 32](https://www.pointfree.co/episodes/ep32-decodable-randomness-part-2): Decodable Randomness: Part 2
- [Episode 47](https://www.pointfree.co/episodes/ep47-predictable-randomness-part-1): Predictable Randomness: Part 1
- [Episode 48](https://www.pointfree.co/episodes/ep48-predictable-randomness-part-2): Predictable Randomness: Part 2
- [Episode 49](https://www.pointfree.co/episodes/ep49-generative-art-part-1): Generative Art: Part 1 🆓
- [Episode 50](https://www.pointfree.co/episodes/ep50-generative-art-part-2): Generative Art: Part 2 🆓

<a href="https://www.pointfree.co/episodes/ep30-composable-randomness">
<img alt="video poster image" src="https://d1hf1soyumxcgv.cloudfront.net/0030-composable-randomness/poster.jpg" width="480">
</a>

## License

All modules are released under the MIT license. See [LICENSE](LICENSE) for details.
