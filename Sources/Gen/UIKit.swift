#if canImport(UIKit)
  import UIKit

  extension Gen where Value == UIColor {
    public static let color = zip(.float(in: 0...1), .float(in: 0...1), .float(in: 0...1))
      .map { (rgb: (Double, Double, Double)) in UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1) }
  }
#endif
