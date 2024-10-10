/// A composable, transformable context for generating random values.
public struct Gen<Value: Sendable>: Sendable {
  @usableFromInline
  internal var _run: @Sendable (inout AnyRandomNumberGenerator) -> Value

  @inlinable
  public init(run: @escaping @Sendable (inout AnyRandomNumberGenerator) -> Value) {
    self._run = run
  }

  /// Returns a random value.
  ///
  /// - Parameter rng: A random number generator.
  /// - Returns: A random value.
  @inlinable
  public func run<G: RandomNumberGenerator>(using rng: inout G) -> Value {
    if var arng = rng as? AnyRandomNumberGenerator {
      defer { rng = arng as! G }
      return self._run(&arng)
    }
    var arng = AnyRandomNumberGenerator(rng)
    defer { rng = arng._rng as! G }
    return self._run(&arng)
  }

  /// Returns a random value.
  ///
  /// - Returns: A random value.
  @inlinable
  public func run() -> Value {
    var rng = SystemRandomNumberGenerator()
    return self.run(using: &rng)
  }
}

extension Gen {
  /// Produces a generator that always returns the same, constant value.
  ///
  /// - Parameter value: A constant value.
  /// - Returns: A generator of a constant value.
  @inlinable
  public static func always(_ value: Value) -> Gen {
    return Gen { _ in value }
  }

  /// Transforms a generator of `Value`s into a generator of `NewValue`s by applying a transformation.
  ///
  /// - Parameter transform: A function that transforms `Value`s into `NewValue`s.
  /// - Returns: A generator of `NewValue`s.
  @inlinable
  public func map<NewValue>(
    _ transform: @escaping @Sendable (Value) -> NewValue
  ) -> Gen<NewValue> {
    return Gen<NewValue> { rng in transform(self._run(&rng)) }
  }
}

extension Gen {
  /// Transforms a generator of `Value`s into a generator of `NewValue`s by transforming a value into a generator of `NewValue`s.
  ///
  /// - Parameter transform: A function that transforms `Value`s into a generator of `NewValue`s.
  /// - Returns: A generator of `NewValue`s.
  @inlinable
  public func flatMap<NewValue>(
    _ transform: @escaping @Sendable (Value) -> Gen<NewValue>
  ) -> Gen<NewValue> {
    return Gen<NewValue> { rng in
      transform(self._run(&rng))._run(&rng)
    }
  }

  /// Returns a generator of the non-nil results of calling the given transformation with a value of the generator.
  ///
  /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
  /// - Returns: A generator of the non-nil results of calling the given transformation with a value of the generator.
  @inlinable
  public func compactMap<NewValue>(
    _ transform: @escaping @Sendable (Value) -> NewValue?
  ) -> Gen<NewValue> {
    return Gen<NewValue> { rng in
      while true {
        if let value = transform(self._run(&rng)) {
          return value
        }
      }
    }
  }

  /// Produces a generator of values that match the predicate.
  ///
  /// - Parameter predicate: A predicate.
  /// - Returns: A generator of values that match the predicate.
  @inlinable
  public func filter(_ predicate: @escaping @Sendable (Value) -> Bool) -> Gen<Value> {
    return self.compactMap { predicate($0) ? $0 : nil }
  }

  /// Uses a weighted distribution to randomly select one of the generators in the list.
  @inlinable
  public static func frequency(_ distribution: (Int, Gen)...) -> Gen {
    return frequency(distribution)
  }

  /// Uses a weighted distribution to randomly select one of the generators in the list.
  @inlinable
  public static func frequency(_ distribution: [(Int, Gen)]) -> Gen {
    // TODO: Add `!distribution.isEmpty` precondition?
    let generators = distribution.flatMap { Array(repeating: $1, count: $0) }
    return Gen { rng in
      Gen<Int>.int(in: 0...generators.count - 1)
        .flatMap { idx in generators[idx] }
        .run(using: &rng)
    }
  }
}

extension Gen where Value: FixedWidthInteger {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value: BinaryFloatingPoint, Value.RawSignificand: FixedWidthInteger {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func float(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen<Int> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<Int8> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int8(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<Int16> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int16(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<Int32> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int32(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<Int64> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int64(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<UInt> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func uint(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<UInt8> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func uint8(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<UInt16> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func uint16(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<UInt32> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func uint32(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<UInt64> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func uint64(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<Double> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func double(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen<Float> {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func float32(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

#if !(os(Windows) || os(Android)) && (arch(i386) || arch(x86_64))
  extension Gen<Float80> {
    /// Returns a generator of random values within the specified range.
    ///
    /// - Parameter range: The range in which to create a random value. `range` must be finite.
    /// - Returns: A generator of random values within the bounds of range.
    @inlinable
    public static func float80(in range: ClosedRange<Value>) -> Gen {
      return Gen { rng in .random(in: range, using: &rng) }
    }
  }
#endif

#if canImport(CoreGraphics)
  import CoreGraphics

  extension Gen<CGFloat> {
    /// Returns a generator of random values within the specified range.
    ///
    /// - Parameter range: The range in which to create a random value. `range` must be finite.
    /// - Returns: A generator of random values within the bounds of range.
    @inlinable
    public static func cgFloat(in range: ClosedRange<Value>) -> Gen {
      return Gen { rng in .random(in: range, using: &rng) }
    }
  }
#endif

extension Gen<Bool> {
  /// A generator of random boolean values.
  public static let bool = Gen { rng in Bool.random(using: &rng) }
}

extension Gen {
  /// Produces a generator of random elements of this generator's collection.
  ///
  /// - Parameter collection: A collection.
  @inlinable
  public static func element<C>(of collection: C) -> Gen
  where C: Collection & Sendable, Value == C.Element? {
    return Gen { rng in collection.randomElement(using: &rng) }
  }

  /// Produces a generator of shuffled arrays of this generator's collection.
  ///
  /// - Parameter collection: A collection.
  @inlinable
  public static func shuffled<C>(_ collection: C) -> Gen
  where C: Collection & Sendable, Value == [C.Element] {
    return Gen { rng in collection.shuffled(using: &rng) }
  }
}

extension Gen where Value: Collection, Value.Element: Sendable {
  /// Produces a generator of random elements of this generator's collection.
  @inlinable
  public var element: Gen<Value.Element?> {
    self.flatMap { Gen<Value.Element?>.element(of: $0) }
  }

  /// Produces a generator of shuffled arrays of this generator's collection.
  @inlinable
  public var shuffled: Gen<[Value.Element]> {
    self.flatMap { Gen<[Value.Element]>.shuffled($0) }
  }
}

extension Gen where Value: CaseIterable, Value.AllCases: Sendable {
  /// Produces a generator of all case-iterable cases.
  @inlinable
  public static var allCases: Gen<Value> {
    return Gen<Value.AllCases>.always(Value.allCases).element.map { $0! }
  }
}

extension Gen {
  /// Produces a new generator of collections of this generator's values.
  ///
  /// - Parameter count: The size of the random collection.
  /// - Returns: A generator of collections.
  @inlinable
  public func collection<C>(of count: Gen<Int>) -> Gen<C>
  where C: RangeReplaceableCollection, C.Element == Value {
    return count.flatMap { count in
      guard count > 0 else { return .always(C()) }
      return Gen<C> { rng in
        var collection = C()
        guard count > 0 else { return collection }
        collection.reserveCapacity(count)
        for _ in 1...count {
          collection.append(self._run(&rng))
        }
        return collection
      }
    }
  }
  
  /// Produces a new generator of arrays of this generator's values.
  ///
  /// - Parameter count: The size of the random array.
  /// - Returns: A generator of arrays.
  @inlinable
  public func array(of count: Gen<Int>) -> Gen<[Value]> {
    return count.flatMap { count in
      guard count > 0 else { return .always([]) }
      return Gen<[Value]> { rng in
        var array: [Value] = []
        array.reserveCapacity(count)
        for _ in 0..<count {
          array.append(self._run(&rng))
        }
        return array
      }
    }
  }
  
  /// Produces a new generator of dictionaries of this generator's pairs.
  ///
  /// - Parameter count: The size of the random dictionary.
  /// - Returns: A generator of dictionaries.
  @inlinable
  public func dictionary<K, V>(ofAtMost count: Gen<Int>) -> Gen<[K: V]> where Value == (K, V) {
    return count.flatMap { count in
      guard count > 0 else { return .always([:]) }
      return Gen<[K: V]> { rng in
        var dictionary: [K: V] = [:]
        dictionary.reserveCapacity(count)
        for _ in 1...count {
          let (k, v) = self._run(&rng)
          dictionary[k] = v
        }
        return dictionary
      }
    }
  }
  
  /// Produces a new generator of sets of this generator's values.
  ///
  /// - Parameter count: The size of the random set.
  /// - Returns: A generator of sets.
  @inlinable
  public func set<S>(ofAtMost count: Gen<Int>) -> Gen<S> where S: SetAlgebra, S.Element == Value {
    return count.flatMap { count in
      guard count > 0 else { return .always(S()) }
      return Gen<S> { rng in
        var set = S()
        for _ in 1...count {
          set.insert(self._run(&rng))
        }
        return set
      }
    }
  }
}

extension Gen {
  /// Produces a new generator of optional values.
  ///
  /// - Returns: A generator of optional values.
  @inlinable
  public var optional: Gen<Value?> {
    return Gen<Value?>.frequency(
      (1, Gen<Value?>.always(Value?.none)),
      (3, self.map { Value?.some($0) })  // TODO: Change to use `size` with resizable generators?
    )
  }

  /// Produces a new generator of failable values.
  ///
  /// - Returns: A generator of failable values.
  @inlinable
  public func asResult<Failure>(withFailure gen: Gen<Failure>) -> Gen<Result<Value, Failure>> {
    return Gen<Result<Value, Failure>>.frequency(
      (1, gen.map { Result.failure($0) }),
      (3, self.map { Result.success($0) })  // TODO: Change to use `size` with resizable generators?
    )
  }
}

extension Gen where Value: Hashable {
  /// Produces a new generator of sets of this generator's values.
  ///
  /// - Parameter count: The size of the random set.
  /// - Returns: A generator of sets.
  @inlinable
  public func set(ofAtMost count: Gen<Int>) -> Gen<Set<Value>> {
    return count.flatMap { count in
      guard count > 0 else { return .always([]) }
      return Gen<Set<Value>> { rng in
        var set: Set<Value> = []
        for _ in 1...count {
          set.insert(self._run(&rng))
        }
        return set
      }
    }
  }
}

extension Gen<UnicodeScalar> {
  /// Returns a generator of random unicode scalars within the specified range.
  ///
  /// - Parameter range: The range in which to create a random unicode scalar. `range` must be finite.
  /// - Returns: A generator of random unicode scalars within the bounds of range.
  @inlinable
  public static func unicodeScalar(in range: ClosedRange<Value>) -> Gen {
    return Gen<UInt32>
      .int(in: range.lowerBound.value...range.upperBound.value)
      .map { UnicodeScalar($0)! }
  }
}

extension Gen<Character> {
  // FIXME: Make safe for characters with multiple scalars.
  /// Returns a generator of random characters within the specified range.
  ///
  /// - Parameter range: The range in which to create a random character. `range` must be finite.
  /// - Returns: A generator of random characters within the bounds of range.
  @inlinable
  public static func character(in range: ClosedRange<Value>) -> Gen {
    return Gen<UnicodeScalar>
      .unicodeScalar(
        in: range.lowerBound.unicodeScalars.first!...range.upperBound.unicodeScalars.last!
      )
      .map { Character($0) }
  }

  /// A generator of random numeric digits.
  public static let number = Gen.character(in: "0"..."9")

  /// A generator of uppercase letters.
  public static let uppercaseLetter = Gen.character(in: "A"..."Z")

  /// A generator of lowercase letters.
  public static let lowercaseLetter = Gen.character(in: "a"..."z")

  /// A generator of uppercase and lowercase letters.
  public static let letter = Gen<Character?>
    .element(of: Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ") as [Character])
    .map { $0! }

  /// A generator of letters and numbers.
  public static let letterOrNumber = Gen<Character?>
    .element(
      of: Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") as [Character]
    )
    .map { $0! }

  /// A generator of ASCII characters.
  public static let ascii = Gen<UInt32>.int(in: 0...127)
    .map { UnicodeScalar($0)! }

  /// A generator of Latin-1 characters.
  public static let latin1 = Gen<UInt32>.int(in: 0...255)
    .map { UnicodeScalar($0)! }

  /// Produces a new generator of strings of this generator's characters.
  ///
  /// - Parameter count: The size of the random string.
  /// - Returns: A generator of strings.
  @inlinable
  public func string(of count: Gen<Int>) -> Gen<String> {
    return self
      .map { String($0) }
      .array(of: count)
      .map { $0.joined() }
  }
}

extension Sequence where Self: Sendable, Element: Sendable {
  /// Transforms each value of an array of generators before rewrapping the array in an array generator.
  ///
  /// - Parameter transform: A transform function to apply to the value of each generator.
  /// - Returns: A generator of arrays.
  @inlinable
  public func traverse<A, B>(
    _ transform: @escaping @Sendable (A) -> B
  ) -> Gen<[B]> where Element == Gen<A> {
    return Gen<[B]> { rng in
      self.map { transform($0.run(using: &rng)) }
    }
  }

  /// Transforms an array of generators into a generator of arrays.
  ///
  /// - Returns: A generator of arrays.
  @inlinable
  public func sequence<A>() -> Gen<[A]> where Element == Gen<A> {
    return self.traverse { $0 }
  }
}
