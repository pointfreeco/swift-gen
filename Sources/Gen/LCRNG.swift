/// A linear congruential random number generator.
@available(
  *, deprecated,
  message:
    "LCRNG has been deprecated due to instability across Swift versions. Use Xoshiro for seedable randomness, instead."
)
public struct LCRNG: RandomNumberGenerator {
  public var seed: UInt64

  @inlinable
  public init(seed: UInt64) {
    self.seed = seed
  }

  @inlinable
  public mutating func next() -> UInt64 {
    seed = 2_862_933_555_777_941_757 &* seed &+ 3_037_000_493
    return seed
  }
}

#if swift(>=5.5)
extension LCRNG: Sendable {}
#endif
