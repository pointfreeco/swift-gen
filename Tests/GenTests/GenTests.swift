import Gen
import XCTest

final class GenTests: XCTestCase {
  var xoshiro = Xoshiro(seed: 0)

  func testMap() {
    let gen = Gen.bool.map { String($0) }
    XCTAssertEqual("false", gen.run(using: &xoshiro))
  }

  func testZip() {
    let (bool, int) = zip(.bool, .int(in: 1...10)).run(using: &xoshiro)
    XCTAssertEqual(false, bool)
    XCTAssertEqual(1, int)
  }

  func testFlatMap() {
    let gen = Gen.bool.flatMap { bool in bool ? .always(1) : .always(2) }
    XCTAssertEqual(2, gen.run(using: &xoshiro))
  }

  func testCompactMap() {
    let gen = Gen.bool.compactMap { bool in bool ? nil : "Compacted!" }
    XCTAssertEqual("Compacted!", gen.run(using: &xoshiro))
  }

  func testFilter() {
    let gen = Gen.bool.filter { bool in !bool }
    XCTAssertEqual(false, gen.run(using: &xoshiro))
  }

  func testAlways() {
    let gen = Gen.always(42)
    XCTAssertEqual(42, gen.run(using: &xoshiro))
  }

  func testArrayOf() {
    let gen = Gen.int(in: 1...100).array(of: .int(in: 2...10))
    XCTAssertEqual([2, 49, 67], gen.run(using: &xoshiro))
  }

  func testArrayOf_DegenerateCase() {
    let gen = Gen.int(in: 1...100).array(of: .int(in: 0...0))
    XCTAssertEqual([], gen.run(using: &xoshiro))
  }

  func testFrequency() {
    let gen = Gen.frequency((1, .always(1)), (4, .always(nil)))
    XCTAssertEqual(
      [1, 1, nil, nil, nil, nil, nil, nil, nil, nil],
      gen.array(of: .always(10)).run(using: &xoshiro))
  }

  func testOptional() {
    let gen = Gen.bool.optional
    XCTAssertEqual(
      [nil, nil, true, false, false, false, false, false, false, nil],
      gen.array(of: .always(10)).run(using: &xoshiro))
  }

  struct Failure: Error, Equatable {}
  func testResult() {
    let gen = Gen.bool.asResult(withFailure: .always(Failure())).array(of: .always(10))
    XCTAssertEqual(
      [
        .failure(.init()),
        .failure(.init()),
        .success(true),
        .success(false),
        .success(false),
        .success(false),
        .success(false),
        .success(false),
        .success(false),
        .failure(.init()),
      ],
      gen.run(using: &xoshiro)
    )
  }

  func testElementOf() {
    XCTAssertEqual("hello", Gen.element(of: ["hello", "goodbye"]).run(using: &xoshiro))
    XCTAssertEqual("hello", Gen.always(["hello", "goodbye"]).element.run(using: &xoshiro))
  }

  func testShuffled() {
    let suit = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    XCTAssertEqual(
      ["2", "A", "8", "10", "4", "3", "5", "7", "J", "9", "K", "6", "Q"],
      Gen.shuffled(suit).run(using: &xoshiro))
    XCTAssertEqual(
      ["K", "7", "A", "6", "4", "9", "Q", "10", "J", "8", "2", "3", "5"],
      Gen.always(suit).shuffled.run(using: &xoshiro))
  }

  func testAllCases() {
    enum Traffic: CaseIterable, Equatable { case green, yellow, red }
    let gen = Gen<Traffic>.allCases
    XCTAssertEqual(.green, gen.run(using: &xoshiro))
  }

  func testTraverse() {
    let gen = [Gen.int(in: 1...100), Gen.int(in: 1_000...1_000_000)].traverse { String($0) }
    XCTAssertEqual(["15", "18473"], gen.run(using: &xoshiro))
  }

  func testSequence() {
    let gen = [Gen.int(in: 1...100), Gen.int(in: 1_000...1_000_000)].sequence()
    XCTAssertEqual([15, 18473], gen.run(using: &xoshiro))
  }

  func testHigherZips() {
    let zip3 = zip(.bool, .bool, .bool).run(using: &xoshiro)
    XCTAssertEqual(false, zip3.0)
    XCTAssertEqual(true, zip3.1)
    XCTAssertEqual(true, zip3.2)

    let zip4 = zip(.bool, .bool, .bool, .bool).run(using: &xoshiro)
    XCTAssertEqual(true, zip4.0)
    XCTAssertEqual(false, zip4.1)
    XCTAssertEqual(false, zip4.2)
    XCTAssertEqual(true, zip4.3)

    let zip5 = zip(.bool, .bool, .bool, .bool, .bool).run(using: &xoshiro)
    XCTAssertEqual(false, zip5.0)
    XCTAssertEqual(false, zip5.1)
    XCTAssertEqual(false, zip5.2)
    XCTAssertEqual(true, zip5.3)
    XCTAssertEqual(false, zip5.4)

    let zip6 = zip(.bool, .bool, .bool, .bool, .bool, .bool).run(using: &xoshiro)
    XCTAssertEqual(true, zip6.0)
    XCTAssertEqual(false, zip6.1)
    XCTAssertEqual(false, zip6.2)
    XCTAssertEqual(false, zip6.3)
    XCTAssertEqual(true, zip6.4)
    XCTAssertEqual(true, zip6.5)

    let zip7 = zip(.bool, .bool, .bool, .bool, .bool, .bool, .bool).run(using: &xoshiro)
    XCTAssertEqual(true, zip7.0)
    XCTAssertEqual(true, zip7.1)
    XCTAssertEqual(true, zip7.2)
    XCTAssertEqual(false, zip7.3)
    XCTAssertEqual(false, zip7.4)
    XCTAssertEqual(true, zip7.5)
    XCTAssertEqual(false, zip7.6)

    let zip8 = zip(.bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool).run(using: &xoshiro)
    XCTAssertEqual(true, zip8.0)
    XCTAssertEqual(false, zip8.1)
    XCTAssertEqual(true, zip8.2)
    XCTAssertEqual(true, zip8.3)
    XCTAssertEqual(true, zip8.4)
    XCTAssertEqual(true, zip8.5)
    XCTAssertEqual(false, zip8.6)
    XCTAssertEqual(true, zip8.7)

    let zip9 = zip(.bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool).run(
      using: &xoshiro)
    XCTAssertEqual(true, zip9.0)
    XCTAssertEqual(false, zip9.1)
    XCTAssertEqual(false, zip9.2)
    XCTAssertEqual(true, zip9.3)
    XCTAssertEqual(false, zip9.4)
    XCTAssertEqual(false, zip9.5)
    XCTAssertEqual(true, zip9.6)
    XCTAssertEqual(false, zip9.7)
    XCTAssertEqual(false, zip9.8)

    let zip10 = zip(.bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool).run(
      using: &xoshiro)
    XCTAssertEqual(false, zip10.0)
    XCTAssertEqual(true, zip10.1)
    XCTAssertEqual(false, zip10.2)
    XCTAssertEqual(true, zip10.3)
    XCTAssertEqual(false, zip10.4)
    XCTAssertEqual(false, zip10.5)
    XCTAssertEqual(false, zip10.6)
    XCTAssertEqual(true, zip10.7)
    XCTAssertEqual(false, zip10.8)
    XCTAssertEqual(false, zip10.9)
  }
}
