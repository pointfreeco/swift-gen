/// An implementation of xoshiro256**: http://xoshiro.di.unimi.it.
public struct Xoshiro: RandomNumberGenerator {
  private var state: (UInt64, UInt64, UInt64, UInt64)

  public init() {
    state = zip(
      .int(in: .min ... .max),
      .int(in: .min ... .max),
      .int(in: .min ... .max),
      .int(in: .min ... .max)
    )
    .run()
  }

  public init(seed: UInt64) {
    self.state = (seed, 18_446_744, 073_709, 551_615)
    for _ in 1...10 { _ = self.next() } // perturb
  }

  public mutating func next() -> UInt64 {
    let x = state.1 &* 5
    let result = ((x &<< 7) | (x &>> 57)) &* 9
    let t = state.1 &<< 17
    state.2 ^= state.0
    state.3 ^= state.1
    state.1 ^= state.2
    state.0 ^= state.3
    state.2 ^= t
    state.3 = (state.3 &<< 45) | (state.3 &>> 19)
    return result
  }
}
