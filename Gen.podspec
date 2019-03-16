Pod::Spec.new do |s|
  s.name = "Gen"
  s.version = "0.1.0"
  s.summary = "TODO"

  s.description = <<-DESC
  TODO
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

  s.swift_version = "4.2"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source_files = "Sources", "Sources/Gen/**/*.swift"
end
