import Gen

zip(.bool, .bool).dictionary(ofAtMost: .always(1)).run()
Gen.bool.set(ofAtMost: .always(3)).run()
Gen.float(in: 0...1)

import CoreGraphics
Gen.float80(in: 0...1)
