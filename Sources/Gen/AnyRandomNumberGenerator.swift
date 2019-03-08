/// A type-erased random number generator.
///
/// The `AnyRandomNumberGenerator` type forwards random number generating operations to an underlying random number generator, hiding its specific underlying type.
public struct AnyRandomNumberGenerator: RandomNumberGenerator {
  @usableFromInline
  internal var _rng: RandomNumberGenerator

  /// - Parameter rng: A random number generator.
  @inlinable
  public init(_ rng: RandomNumberGenerator) {
    self._rng = rng
  }

  @inlinable
  public mutating func next() -> UInt64 {
    return self._rng.next()
  }
}
