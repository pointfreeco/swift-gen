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

Swift's randomness API is powerful and simple to use. It allows us to create random values from many basic types, such as booleans and numeric types, and it allows us to randomly shuffle arrays and pluck random elements from collections.

However, it does not make it easy for us to extend the randomness API, nor does it provide an API that is composable, which would allow us to create complex types of randomness from simpler pieces.


Gen is a lightweight wrapper over Swift's randomness APIs that makes it easy to build custom generators of any kind of value.

## Examples

Gen's namesake type, `Gen`, is responsible for producing random values. Most often you will reach for one of the static variables inside `Gen` to get access to a `Gen` value:

``` swift
Gen.bool
// Gen<Bool>
```

Rather than immediately producing a random value, `Gen` describes a random value that can be produced by calling its `run` method:

``` swift
let myGen = Gen.bool
// Gen<Bool>

myGen.run() // true
myGen.run() // true
myGen.run() // false
```

Every random function that comes with Swift is also available as a static function on `Gen`:

|  Swift's API | Gen's API |
| --- | --- |
| `Int.random(in: 0...9)` | `Gen.int(in: 0...9)` |                       
| `Double.random(in: 0...9)` | `Gen.double(in: 0...9)` |                       
| `Bool.random()` | `Gen.bool` |                       
| `[1, 2, 3].randomElement()` | `Gen.element(of: [1, 2, 3])` |                       
| `[1, 2, 3].shuffled()` | `Gen.shuffle([1, 2, 3])` |                       

The reason it is powerful to wrap randomness in the `Gen` type is that we can make the `Gen` type composable. For example, a generator of integers can be turned into a generator of numeric strings with a simple application of the `map` function:

``` swift
let digit = Gen.int(in: 0...9)           // Gen<Int>
let stringDigit = digit.map(String.init) // Gen<String>

stringDigit.run() // "7"
stringDigit.run() // "1"
stringDigit.run() // "3"
```

Already this is a form of randomness that Swift's API's do not provide out of the box.

Gen provides many operators for generating new types of randomness, such as `map`, `flatMap` and `zip`, as well as helper functions for generating random arrays, sets, dictionaries, strings, distributions and more!

But composability isn't the only reason the `Gen` type shines. By delaying the creation of random values until the `run` method is invoked, we allow ourselves to control randomness in circumstances where we need determinism, such as tests. The `run` method has an overload that takes a `RandomNumberGenerator` value, which is Swift's protocol that powers their randomness API. By default it uses the `SystemRandomNumberGenerator`, which is a good source of randomness, but we can also provide a seedable "pseudo" random number generator, so that we can get predictable results in tests:

``` swift
var lcrng = LCRNG(seed: 0)
Gen.int(in: 0...9).run(using: &lcrng) // "8"
Gen.int(in: 0...9).run(using: &lcrng) // "1"
Gen.int(in: 0...9).run(using: &lcrng) // "7"

lcrng.seed = 0
Gen.int(in: 0...9).run(using: &lcrng) // "8"
Gen.int(in: 0...9).run(using: &lcrng) // "1"
Gen.int(in: 0...9).run(using: &lcrng) // "7"
```

This means you don't have to sacrifice testability when leveraging randomness in your application.

For more examples of using Gen to build complex randomness, see our [blog post](https://www.pointfree.co/blog/posts/19-random-zalgo-generator) on creating a Zalgo generator and our two-part video series ([part 1](https://www.pointfree.co/episodes/ep49-generative-art-part-1) and [part 2](https://www.pointfree.co/episodes/ep50-generative-art-part-2)) on creating generative art.

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
