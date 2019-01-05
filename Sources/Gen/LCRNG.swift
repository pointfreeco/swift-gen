public struct LCRNG: RandomNumberGenerator {
  public var seed: UInt64

  public init(seed: UInt64) {
    self.seed = seed
  }

  public mutating func next() -> UInt64 {
    seed = 2862933555777941757 &* seed &+ 3037000493
    return seed
  }
}
