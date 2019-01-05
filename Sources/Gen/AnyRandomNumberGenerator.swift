/// A type-erased random number generator.
///
/// The `AnyRandomNumberGenerator` type forwards random number generating operations to an underlying random number generator, hiding its specific underlying type.
public struct AnyRandomNumberGenerator: RandomNumberGenerator {
  internal var rng: RandomNumberGenerator

  /// - Parameter rng: A random number generator.
  public init(_ rng: RandomNumberGenerator) {
    self.rng = rng
  }

  public mutating func next() -> UInt64 {
    return self.rng.next()
  }
}
