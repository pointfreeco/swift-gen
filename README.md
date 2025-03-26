# 🎱 Gen

[![CI](https://github.com/pointfreeco/swift-gen/actions/workflows/ci.yml/badge.svg)](https://github.com/pointfreeco/swift-gen/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpointfreeco%2Fswift-gen%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/pointfreeco/swift-gen)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpointfreeco%2Fswift-gen%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/pointfreeco/swift-gen)

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

Gen provides many operators for generating new types of randomness, such as `map`, `flatMap` and `zip`, as well as helper functions for generating random arrays, sets, dictionaries, strings, distributions and more! A random password generator, for example, is just a few operators away.

``` swift
// Take a generator of random letters and numbers.
let password = Gen.letterOrNumber
  // Generate 6-character strings of them.
  .string(of: .always(6))
  // Generate 3 segments of these strings.
  .array(of: .always(3))
  // And join them.
  .map { $0.joined(separator: "-") }

password.run() // "9BiGYA-fmvsOf-VYDtDv"
password.run() // "dS2MGr-FQSuC4-ZLEicl"
password.run() // "YusZGF-HILrCo-rNGfCA"
```

This kind of composition makes it simple to generate random values of anything.

``` swift
// Use `zip` to combine generators together and build structures.

let randomPoint = zip(.int(in: -10...10), .int(in: -10...10))
  .map(CGPoint.init(x:y:))
// Gen<CGPoint>
```

But composability isn't the only reason the `Gen` type shines. By delaying the creation of random values until the `run` method is invoked, we allow ourselves to control randomness in circumstances where we need determinism, such as tests. The `run` method has an overload that takes a `RandomNumberGenerator` value, which is Swift's protocol that powers their randomness API. By default it uses the `SystemRandomNumberGenerator`, which is a good source of randomness, but we can also provide a seedable "pseudo" random number generator, so that we can get predictable results in tests:

``` swift
var xoshiro = Xoshiro(seed: 0)
Gen.int(in: 0...9).run(using: &xoshiro) // "1"
Gen.int(in: 0...9).run(using: &xoshiro) // "0"
Gen.int(in: 0...9).run(using: &xoshiro) // "4"

xoshiro = Xoshiro(seed: 0)
Gen.int(in: 0...9).run(using: &xoshiro) // "1"
Gen.int(in: 0...9).run(using: &xoshiro) // "0"
Gen.int(in: 0...9).run(using: &xoshiro) // "4"
```

This means you don't have to sacrifice testability when leveraging randomness in your application.

For more examples of using Gen to build complex randomness, see our [blog post](https://www.pointfree.co/blog/posts/19-random-zalgo-generator) on creating a Zalgo generator and our two-part video series ([part 1](https://www.pointfree.co/episodes/ep49-generative-art-part-1) and [part 2](https://www.pointfree.co/episodes/ep50-generative-art-part-2)) on creating generative art.

## Installation

If you want to use Gen in a project that uses [SwiftPM](https://swift.org/package-manager/), it's as simple as adding a `dependencies` clause to your `Package.swift`:

``` swift
dependencies: [
  .package(url: "https://github.com/pointfreeco/swift-gen.git", from: "0.4.0")
]
```

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
  <img alt="video poster image" src="https://d3rccdn33rt8ze.cloudfront.net/episodes/0030.jpeg" width="600">
</a>

## License

All modules are released under the MIT license. See [LICENSE](LICENSE) for details.
