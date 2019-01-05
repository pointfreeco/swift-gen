#if canImport(CoreGraphics)
import CoreGraphics

extension Gen where A == CGFloat {
  public static func cgFloat(in range: ClosedRange<CGFloat>) -> Gen {
    return Gen { rng in CGFloat.random(in: range, using: &rng) }
  }
}
#endif
