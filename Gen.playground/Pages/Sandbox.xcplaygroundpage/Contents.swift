import Gen

Gen.zip(.bool, .bool).dictionary(of: .always(1)).run()
Gen.bool.set(of: .always(1)).run()
Gen.character(in: "👪"..."👨‍👧‍👧")
