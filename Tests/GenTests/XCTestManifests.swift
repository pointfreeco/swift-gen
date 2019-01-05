import XCTest

extension GenTests {
    static let __allTests = [
        ("testAllCases", testAllCases),
        ("testAlways", testAlways),
        ("testArrayOf", testArrayOf),
        ("testArrayOf_DegenerateCase", testArrayOf_DegenerateCase),
        ("testCompactMap", testCompactMap),
        ("testElementOf", testElementOf),
        ("testFilter", testFilter),
        ("testFlatMap", testFlatMap),
        ("testFrequency", testFrequency),
        ("testHigherZips", testHigherZips),
        ("testMap", testMap),
        ("testOptional", testOptional),
        ("testResult", testResult),
        ("testSequence", testSequence),
        ("testShuffled", testShuffled),
        ("testTraverse", testTraverse),
        ("testZip", testZip),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GenTests.__allTests),
    ]
}
#endif
