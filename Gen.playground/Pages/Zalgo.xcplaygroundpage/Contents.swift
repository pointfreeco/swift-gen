import Gen

// A Zalgo character is a UTF8 character in the "combining character" range.
// See: https://en.wikipedia.org/wiki/Combining_character
let zalgo = Gen.int(in: 0x300 ... 0x36f)
  .map { String(UnicodeScalar($0)!) }

// Here's what some Zalgo characters look like
zalgo.run()
zalgo.run()
zalgo.run()
zalgo.run()

// Given an intensity, combines a random number of Zalgo characters into a single string.
func zalgos(intensity: Gen<Int>) -> Gen<String> {
  return zalgo
    .array(of: intensity)
    .map { $0.joined() }
}

let tameZalgos   = zalgos(intensity: .int(in: 0...1))
let lowZalgos    = zalgos(intensity: .int(in: 1...5))
let mediumZalgos = zalgos(intensity: .int(in: 0...10))
let highZalgos   = zalgos(intensity: .int(in: 0...20))

"a" + tameZalgos.run()

"a" + lowZalgos.run()

"a" + mediumZalgos.run()

"a" + highZalgos.run()

// Given a way to generate a bunch of Zalgo characters, this will return a function that can "Zalgo-ify" any string given to it.
func zalgoify(with zalgos: Gen<String>) -> (String) -> Gen<String> {
  return { string in
    return Gen { rng in
      string
        .map { char in String(char) + zalgos.run(using: &rng) }
        .joined()
    }
  }
}

let tameZalgoify   = zalgoify(with: tameZalgos)
let lowZalgoify    = zalgoify(with: lowZalgos)
let mediumZalgoify = zalgoify(with: mediumZalgos)
let highZalgoify   = zalgoify(with: highZalgos)

tameZalgoify("What’s the point?").run()

lowZalgoify("What’s the point?").run()

mediumZalgoify("What’s the point?").run()

highZalgoify("What’s the point?").run()
