import XCTest
import Gen

final class GenTests: XCTestCase {
  var lcrng = LCRNG(seed: 0)

  func testMap() {
    let gen = Gen.bool.map(String.init)
    XCTAssertEqual("true", gen.run(using: &lcrng))
  }

  func testZip() {
    let (bool, int) = zip(.bool, .int(in: 1...10)).run(using: &lcrng)
    XCTAssertEqual(true, bool)
    XCTAssertEqual(9, int)
  }

  func testFlatMap() {
    let gen = Gen.bool.flatMap { bool in bool ? .always(1) : .always(2) }
    XCTAssertEqual(1, gen.run(using: &lcrng))
  }

  func testCompactMap() {
    let gen = Gen.bool.compactMap { bool in bool ? nil : "Compacted!" }
    XCTAssertEqual("Compacted!", gen.run(using: &lcrng))
  }

  func testFilter() {
    let gen = Gen.bool.filter { bool in !bool }
    XCTAssertEqual(false, gen.run(using: &lcrng))
  }

  func testAlways() {
    let gen = Gen.always(42)
    XCTAssertEqual(42, gen.run(using: &lcrng))
  }

  func testArrayOf() {
    let gen = Gen.int(in: 1...100).array(of: .int(in: 0...10))
    XCTAssertEqual([39, 24, 45, 86, 59, 100, 65, 50, 43, 36], gen.run(using: &lcrng))
  }

  func testArrayOf_DegenerateCase() {
    let gen = Gen.int(in: 1...100).array(of: .int(in: 0...0))
    XCTAssertEqual([], gen.run(using: &lcrng))
  }

  func testFrequency() {
    let gen = Gen.frequency((1, .always(1)), (4, .always(nil)))
    XCTAssertEqual([nil, nil, nil, nil, 1, nil, nil, nil, nil, nil], gen.array(of: .always(10)).run(using: &lcrng))
  }

  func testOptional() {
    let gen = Gen.bool.optional
    lcrng.seed = 777
    XCTAssertEqual([true, nil, true, true, true, true, false, false, true, false], gen.array(of: .always(10)).run(using: &lcrng))
  }

  func testResult() {
    #if swift(>=5.0)
    struct Failure: Error, Equatable {}
    let gen = Gen.bool.asResult(withFailure: .always(Failure())).array(of: .always(10))
    lcrng.seed = 777
    XCTAssertEqual([.success(true), .failure(.init()), .success(true), .success(true), .success(true), .success(true), .success(false), .success(false), .success(true), .success(false)], gen.run(using: &lcrng))
    #endif
  }

  func testElementOf() {
    XCTAssertEqual("goodbye", Gen.element(of: ["hello", "goodbye"]).run(using: &lcrng))
    XCTAssertEqual("hello", Gen.always(["hello", "goodbye"]).element.run(using: &lcrng))
  }

  func testShuffled() {
    let suit = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    XCTAssertEqual(["8", "4", "9", "A", "Q", "2", "7", "6", "K", "5", "10", "J", "3"], Gen.shuffled(suit).run(using: &lcrng))
    XCTAssertEqual(["7", "4", "K", "Q", "8", "2", "5", "A", "3", "6", "10", "J", "9"], Gen.always(suit).shuffled.run(using: &lcrng))
  }

  func testAllCases() {
    enum Traffic: CaseIterable, Equatable { case green, yellow, red }
    let gen = Gen<Traffic>.allCases
    XCTAssertEqual(.red, gen.run(using: &lcrng))
  }

  func testTraverse() {
    let gen = [Gen.int(in: 1...100), Gen.int(in: 1_000...1_000_000)].traverse(String.init)
    XCTAssertEqual(["94", "348083"], gen.run(using: &lcrng))
  }

  func testSequence() {
    let gen = [Gen.int(in: 1...100), Gen.int(in: 1_000...1_000_000)].sequence()
    XCTAssertEqual([94, 348083], gen.run(using: &lcrng))
  }

  func testHigherZips() {
    let zip3 = zip(.bool, .bool, .bool).run(using: &lcrng)
    XCTAssertEqual(true, zip3.0)
    XCTAssertEqual(true, zip3.1)
    XCTAssertEqual(true, zip3.2)

    let zip4 = zip(.bool, .bool, .bool, .bool).run(using: &lcrng)
    XCTAssertEqual(false, zip4.0)
    XCTAssertEqual(false, zip4.1)
    XCTAssertEqual(true, zip4.2)
    XCTAssertEqual(false, zip4.3)

    let zip5 = zip(.bool, .bool, .bool, .bool, .bool).run(using: &lcrng)
    XCTAssertEqual(false, zip5.0)
    XCTAssertEqual(true, zip5.1)
    XCTAssertEqual(false, zip5.2)
    XCTAssertEqual(false, zip5.3)
    XCTAssertEqual(false, zip5.4)

    let zip6 = zip(.bool, .bool, .bool, .bool, .bool, .bool).run(using: &lcrng)
    XCTAssertEqual(false, zip6.0)
    XCTAssertEqual(true, zip6.1)
    XCTAssertEqual(false, zip6.2)
    XCTAssertEqual(true, zip6.3)
    XCTAssertEqual(false, zip6.4)
    XCTAssertEqual(false, zip6.5)

    let zip7 = zip(.bool, .bool, .bool, .bool, .bool, .bool, .bool).run(using: &lcrng)
    XCTAssertEqual(true, zip7.0)
    XCTAssertEqual(true, zip7.1)
    XCTAssertEqual(true, zip7.2)
    XCTAssertEqual(false, zip7.3)
    XCTAssertEqual(false, zip7.4)
    XCTAssertEqual(true, zip7.5)
    XCTAssertEqual(false, zip7.6)

    let zip8 = zip(.bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool).run(using: &lcrng)
    XCTAssertEqual(true, zip8.0)
    XCTAssertEqual(true, zip8.1)
    XCTAssertEqual(false, zip8.2)
    XCTAssertEqual(false, zip8.3)
    XCTAssertEqual(true, zip8.4)
    XCTAssertEqual(true, zip8.5)
    XCTAssertEqual(true, zip8.6)
    XCTAssertEqual(false, zip8.7)

    let zip9 = zip(.bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool).run(using: &lcrng)
    XCTAssertEqual(true, zip9.0)
    XCTAssertEqual(false, zip9.1)
    XCTAssertEqual(false, zip9.2)
    XCTAssertEqual(true, zip9.3)
    XCTAssertEqual(false, zip9.4)
    XCTAssertEqual(true, zip9.5)
    XCTAssertEqual(false, zip9.6)
    XCTAssertEqual(true, zip9.7)
    XCTAssertEqual(false, zip9.8)

    let zip10 = zip(.bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool, .bool).run(using: &lcrng)
    XCTAssertEqual(true, zip10.0)
    XCTAssertEqual(false, zip10.1)
    XCTAssertEqual(false, zip10.2)
    XCTAssertEqual(false, zip10.3)
    XCTAssertEqual(true, zip10.4)
    XCTAssertEqual(false, zip10.5)
    XCTAssertEqual(true, zip10.6)
    XCTAssertEqual(true, zip10.7)
    XCTAssertEqual(true, zip10.8)
    XCTAssertEqual(true, zip10.9)
  }
}
