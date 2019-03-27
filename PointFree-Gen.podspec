Pod::Spec.new do |s|
  s.name = "PointFree-Gen"
  s.module_name = "Gen"
  s.version = "0.2.0"
  s.summary = "Composable, transformable, controllable randomness."

  s.description = <<-DESC
  Swift's randomness API is powerful and simple to use. It allows us to create
  random values from many basic types, such as booleans and numeric types, and
  it allows us to randomly shuffle arrays and pluck random elements from
  collections.

  However, it does not make it easy for us to extend the randomness API, nor
  does it provide an API that is composable, which would allow us to create
  complex types of randomness from simpler pieces.

  Gen is a lightweight wrapper over Swift's randomness APIs that makes it easy
  to build custom generators of any kind of value.
  DESC

  s.homepage = "https://github.com/pointfreeco/swift-gen"

  s.license = "MIT"

  s.authors = {
    "Brandon Williams" => "mbw234@gmail.com",
    "Stephen Celis" => "stephen@stephencelis.com"
  }
  s.social_media_url = "https://twitter.com/pointfreeco"

  s.source = {
    :git => "https://github.com/pointfreeco/swift-gen.git",
    :tag => s.version
  }

  s.swift_version = "5.0"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source_files = "Sources", "Sources/Gen/**/*.swift"
end
