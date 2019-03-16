extension Gen {
  @inlinable
  public static func zip<A, B, C>(
    _ a: Gen<A>,
    _ b: Gen<B>,
    _ c: Gen<C>
    )
    -> Gen where Value == (A, B, C) {
      return Gen<((A, B), C)>
        .zip(.zip(a, b), c)
        .map { ($0.0, $0.1, $1) }
  }

  @inlinable
  public static func zip<A, B, C, D>(
    _ a: Gen<A>,
    _ b: Gen<B>,
    _ c: Gen<C>,
    _ d: Gen<D>
    )
    -> Gen where Value == (A, B, C, D) {
      return Gen<((A, B), C, D)>
        .zip(.zip(a, b), c, d)
        .map { ($0.0, $0.1, $1, $2) }
  }

  @inlinable
  public static func zip<A, B, C, D, E>(
    _ a: Gen<A>,
    _ b: Gen<B>,
    _ c: Gen<C>,
    _ d: Gen<D>,
    _ e: Gen<E>
    )
    -> Gen where Value == (A, B, C, D, E) {
      return Gen<((A, B), C, D, E)>
        .zip(.zip(a, b), c, d, e)
        .map { ($0.0, $0.1, $1, $2, $3) }
  }

  @inlinable
  public static func zip<A, B, C, D, E, F>(
    _ a: Gen<A>,
    _ b: Gen<B>,
    _ c: Gen<C>,
    _ d: Gen<D>,
    _ e: Gen<E>,
    _ f: Gen<F>
    )
    -> Gen where Value == (A, B, C, D, E, F) {
      return Gen<((A, B), C, D, E, F)>
        .zip(.zip(a, b), c, d, e, f)
        .map { ($0.0, $0.1, $1, $2, $3, $4) }
  }

  @inlinable
  public static func zip<A, B, C, D, E, F, G>(
    _ a: Gen<A>,
    _ b: Gen<B>,
    _ c: Gen<C>,
    _ d: Gen<D>,
    _ e: Gen<E>,
    _ f: Gen<F>,
    _ g: Gen<G>
    )
    -> Gen where Value == (A, B, C, D, E, F, G) {
      return Gen<((A, B), C, D, E, F, G)>
        .zip(.zip(a, b), c, d, e, f, g)
        .map { ($0.0, $0.1, $1, $2, $3, $4, $5) }
  }

  @inlinable
  public static func zip<A, B, C, D, E, F, G, H>(
    _ a: Gen<A>,
    _ b: Gen<B>,
    _ c: Gen<C>,
    _ d: Gen<D>,
    _ e: Gen<E>,
    _ f: Gen<F>,
    _ g: Gen<G>,
    _ h: Gen<H>
    )
    -> Gen where Value == (A, B, C, D, E, F, G, H) {
      return Gen<((A, B), C, D, E, F, G, H)>
        .zip(.zip(a, b), c, d, e, f, g, h)
        .map { ($0.0, $0.1, $1, $2, $3, $4, $5, $6) }
  }

  @inlinable
  public static func zip<A, B, C, D, E, F, G, H, I>(
    _ a: Gen<A>,
    _ b: Gen<B>,
    _ c: Gen<C>,
    _ d: Gen<D>,
    _ e: Gen<E>,
    _ f: Gen<F>,
    _ g: Gen<G>,
    _ h: Gen<H>,
    _ i: Gen<I>
    )
    -> Gen where Value == (A, B, C, D, E, F, G, H, I) {
      return Gen<((A, B), C, D, E, F, G, H, I)>
        .zip(.zip(a, b), c, d, e, f, g, h, i)
        .map { ($0.0, $0.1, $1, $2, $3, $4, $5, $6, $7) }
  }

  @inlinable
  public static func zip<A, B, C, D, E, F, G, H, I, J>(
    _ a: Gen<A>,
    _ b: Gen<B>,
    _ c: Gen<C>,
    _ d: Gen<D>,
    _ e: Gen<E>,
    _ f: Gen<F>,
    _ g: Gen<G>,
    _ h: Gen<H>,
    _ i: Gen<I>,
    _ j: Gen<J>
    )
    -> Gen where Value == (A, B, C, D, E, F, G, H, I, J) {
      return Gen<((A, B), C, D, E, F, G, H, I, J)>
        .zip(.zip(a, b), c, d, e, f, g, h, i, j)
        .map { ($0.0, $0.1, $1, $2, $3, $4, $5, $6, $7, $8) }
  }
}
