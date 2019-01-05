/// A composable, transformable context for generating random values.
public struct Gen<Value> {
  internal let gen: (inout AnyRandomNumberGenerator) -> Value

  /// Returns a random value.
  ///
  /// - Parameter rng: A random number generator.
  /// - Returns: A random value.
  public func run<G: RandomNumberGenerator>(using rng: inout G) -> Value {
    var arng = AnyRandomNumberGenerator(rng)
    defer { rng = arng.rng as! G }
    return self.gen(&arng)
  }

  /// Returns a random value.
  ///
  /// - Returns: A random value.
  public func run() -> Value {
    var rng = SystemRandomNumberGenerator()
    return self.run(using: &rng)
  }
}

extension Gen {
  /// Transforms a generator of `Value`s into a generator of `NewValue`s by applying a transformation.
  ///
  /// - Parameter transform: A function that transforms `Value`s into `NewValue`s.
  /// - Returns: A generator of `NewValue`s.
  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Gen<NewValue> {
    return Gen<NewValue> { rng in transform(self.gen(&rng)) }
  }

  /// Transforms a generator of `Value`s into a generator of `NewValue`s by transforming a value into a generator of `NewValue`s.
  ///
  /// - Parameter transform: A function that transforms `Value`s into a generator of `NewValue`s.
  /// - Returns: A generator of `NewValue`s.
  public func flatMap<NewValue>(_ transform: @escaping (Value) -> Gen<NewValue>) -> Gen<NewValue> {
    return Gen<NewValue> { rng in
      transform(self.run(using: &rng)).run(using: &rng)
    }
  }

  /// Returns a generator of the non-nil results of calling the given transformation with a value of the generator.
  ///
  /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
  /// - Returns: A generator of the non-nil results of calling the given transformation with a value of the generator.
  public func compactMap<NewValue>(_ transform: @escaping (Value) -> NewValue?) -> Gen<NewValue> {
    return Gen<NewValue> { rng in
      while true {
        if let value = transform(self.run(using: &rng)) {
          return value
        }
      }
    }
  }

  /// Produces a generator of values that match the predicate.
  ///
  /// - Parameter predicate: A predicate.
  /// - Returns: A generator of values that match the predicate.
  public func filter(_ predicate: @escaping (Value) -> Bool) -> Gen<Value> {
    return self.compactMap { predicate($0) ? $0 : nil }
  }
}

/// Combines two generators into a single one.
///
/// - Parameters:
///   - a: A generator of `A`s.
///   - b: A generator of `B`s.
/// - Returns: A generator of `(A, B)` pairs.
public func zip<A, B>(_ a: Gen<A>, _ b: Gen<B>) -> Gen<(A, B)> {
  return Gen<(A, B)> { rng in
    (a.gen(&rng), b.gen(&rng))
  }
}

extension Gen {
  /// Produces a generator that always returns the same, constant value.
  ///
  /// - Parameter value: A constant value.
  /// - Returns: A generator of a constant value.
  public static func always(_ value: Value) -> Gen {
    return Gen { _ in value }
  }

  /// Produces a new generator of arrays of this generator's values.
  ///
  /// - Parameter count: The size of the random array.
  /// - Returns: A generator of arrays.
  public func array(of count: Gen<Int>) -> Gen<[Value]> {
    return count.flatMap { count in
      Gen<[Value]> { rng in
        var array: [Value] = []
        array.reserveCapacity(count)
        for _ in 1...count {
          array.append(self.run(using: &rng))
        }
        return array
      }
    }
  }

  /// Uses a weighted distribution to randomly select one of the generators in the list.
  public static func frequency(_ distribution: (Int, Gen)...) -> Gen {
    let generators = distribution.flatMap { Array(repeating: $1, count: $0) }
    return Gen { rng in
      Gen<Int>.int(in: 0...generators.count)
        .flatMap { idx in generators[idx] }
        .run(using: &rng)
    }
  }

  /// Produces a new generator of optional values.
  ///
  /// - Parameter count: The size of the random array.
  /// - Returns: A generator of arrays.
  public var optional: Gen<Value?> {
    return Gen<Value?>.frequency(
      (1, Gen<Value?>.always(Value?.none)),
      (3, self.map(Value?.some)) // TODO: Change to use `size`?
    )
  }
}

extension Gen where Value: FixedWidthInteger {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value: BinaryFloatingPoint, Value.RawSignificand: FixedWidthInteger {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  public static func float(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == Bool {
  /// A generator of random boolean values.
  public static let bool = Gen { rng in Bool.random(using: &rng) }
}

extension Gen where Value: Collection {
  /// Produces a generator of random elements of this generator's collection.
  public var element: Gen<Value.Element?> {
    return Gen<Value.Element?> { rng in
      self.gen(&rng).randomElement(using: &rng)
    }
  }
}

extension Sequence {
  /// Transforms each value of an array of generators before rewrapping the array in an array generator.
  ///
  /// - Parameter transform: A transform function to apply to the value of each generator.
  /// - Returns: A generator of arrays.
  public func traverse<A, B>(_ transform: @escaping (A) -> B) -> Gen<[B]> where Element == Gen<A> {
    return Gen<[B]> { rng in
      self.map { transform($0.run(using: &rng)) }
    }
  }

  /// Transforms an array of generators into a generator of arrays.
  ///
  /// - Returns: A generator of arrays.
  public func sequence<A>() -> Gen<[A]> where Element == Gen<A> {
    return self.traverse { $0 }
  }
}
