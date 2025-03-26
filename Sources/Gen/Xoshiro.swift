/// An implementation of xoshiro256**: http://xoshiro.di.unimi.it.
public struct Xoshiro: RandomNumberGenerator {
  @usableFromInline
  var state: (UInt64, UInt64, UInt64, UInt64)

  @inlinable
  public init() {
    self.state = zip(
      Gen<UInt64>.int(in: .min ... .max),
      Gen<UInt64>.int(in: .min ... .max),
      Gen<UInt64>.int(in: .min ... .max),
      Gen<UInt64>.int(in: .min ... .max)
    )
    .run()
  }

  @inlinable
  public init(seed: UInt64) {
    self.state = (seed, 18_446_744, 073_709, 551_615)
    for _ in 1...10 { _ = self.next() }  // perturb
  }

  @inlinable
  public mutating func next() -> UInt64 {
    // Adopted from https://github.com/mattgallagher/CwlUtils/blob/0bfc4587d01cfc796b6c7e118fc631333dd8ab33/Sources/CwlUtils/CwlRandom.swift
    let x = self.state.1 &* 5
    let result = ((x &<< 7) | (x &>> 57)) &* 9
    let t = self.state.1 &<< 17
    self.state.2 ^= self.state.0
    self.state.3 ^= self.state.1
    self.state.1 ^= self.state.2
    self.state.0 ^= self.state.3
    self.state.2 ^= t
    self.state.3 = (self.state.3 &<< 45) | (self.state.3 &>> 19)
    return result
  }
}

extension Xoshiro {
  /// Initialize with a full state.
  ///
  /// Useful for getting an exact value from `next()` after multiple runs of the RNG.
  @inlinable
  public init(state: (UInt64, UInt64, UInt64, UInt64)) {
    self.state = state
  }

  /// Get the latest internal state of the RNG.
  ///
  /// Can be used in combination with `init(state:)` to run the RNG from a specific state, e.g. in the context of a property-based test.
  public var currentState: (UInt64, UInt64, UInt64, UInt64) {
    state
  }
}
