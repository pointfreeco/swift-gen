import XCTest
@testable import Gen

final class GenTests: XCTestCase {
  func testExample() {
    enum Light: CaseIterable {
      case red, green, yellow
    }
  }
  
  static var allTests = [
    ("testExample", testExample),
    ]
}
