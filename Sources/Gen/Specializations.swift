extension Gen where Value == Int {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == Int8 {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == Int16 {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == Int32 {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == Int64 {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == UInt8 {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == UInt16 {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == UInt32 {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == UInt64 {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == Double {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func float(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == Float {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func float(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

extension Gen where Value == Float80 {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func float(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}

#if canImport(CoreGraphics)
import CoreGraphics

extension Gen where Value == CGFloat {
  /// Returns a generator of random values within the specified range.
  ///
  /// - Parameter range: The range in which to create a random value. `range` must be finite.
  /// - Returns: A generator of random values within the bounds of range.
  @inlinable
  public static func int(in range: ClosedRange<Value>) -> Gen {
    return Gen { rng in Value.random(in: range, using: &rng) }
  }
}
#endif
