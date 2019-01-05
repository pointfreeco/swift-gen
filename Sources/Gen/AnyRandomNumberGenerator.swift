public struct AnyRandomNumberGenerator: RandomNumberGenerator {
  var rng: RandomNumberGenerator

  public init(_ rng: RandomNumberGenerator) {
    self.rng = rng
  }

  public mutating func next() -> UInt64 {
    return self.rng.next()
  }
}
