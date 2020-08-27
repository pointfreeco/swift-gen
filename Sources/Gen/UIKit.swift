#if canImport(UIKit)
  import UIKit

  extension Gen where Value == UIColor {
    public static let color = zip(.float(in: 0...1), .float(in: 0...1), .float(in: 0...1))
      .map { UIColor(red: $0, green: $1, blue: $2, alpha: 1) }
  }
#endif
