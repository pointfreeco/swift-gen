public struct Gen<Value> {
  let gen: (inout AnyRandomNumberGenerator) -> Value

  public func run<G: RandomNumberGenerator>(using rng: inout G) -> Value {
    var arng = AnyRandomNumberGenerator(rng)
    defer { rng = arng.rng as! G }
    return self.gen(&arng)
  }

  public func run() -> Value {
    var rng = SystemRandomNumberGenerator()
    return self.run(using: &rng)
  }
}

extension Gen {
  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Gen<NewValue> {
    return Gen<NewValue> { rng in transform(self.gen(&rng)) }
  }
}

public func zip<A, B>(_ a: Gen<A>, _ b: Gen<B>) -> Gen<(A, B)> {
  return Gen<(A, B)> { rng in
    (a.gen(&rng), b.gen(&rng))
  }
}

extension Gen {
  public func flatMap<NewValue>(_ transform: @escaping (Value) -> Gen<NewValue>) -> Gen<NewValue> {
    return Gen<NewValue> { rng in
      transform(self.run(using: &rng)).run(using: &rng)
    }
  }
}

extension Gen where Value == Int {
  public static func int(in range: ClosedRange<Int>) -> Gen {
    return Gen { rng in Int.random(in: range, using: &rng) }
  }
}

extension Gen where Value == Double {
  public static func double(in range: ClosedRange<Double>) -> Gen {
    return Gen { rng in Double.random(in: range, using: &rng) }
  }
}

extension Gen where Value == Bool {
  public static let bool = Gen { rng in Bool.random(using: &rng) }
}

extension Gen where Value: Collection {
  public var element: Gen<Value.Element?> {
    return Gen<Value.Element?> { rng in
      self.gen(&rng).randomElement(using: &rng)
    }
  }
}

extension Gen {
  public static func always(_ value: Value) -> Gen {
    return Gen { _ in value }
  }

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
}

extension Sequence {
  public func traverse<A, B>(_ transform: @escaping (A) -> B) -> Gen<[B]> where Element == Gen<A> {
    return Gen<[B]> { rng in
      self.map { transform($0.run(using: &rng)) }
    }
  }

  public func sequence<A>() -> Gen<[A]> where Element == Gen<A> {
    return self.traverse { $0 }
  }
}
