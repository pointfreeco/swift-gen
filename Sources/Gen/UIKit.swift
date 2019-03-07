#if canImport(UIKit)
import UIKit

extension Gen where Value == UIColor {
  public static let color = zip(
    with: UIColor.init(red:green:blue:alpha:),
    .float(in: 0...1),
    .float(in: 0...1),
    .float(in: 0...1),
    .always(1)
    )
}
#endif
