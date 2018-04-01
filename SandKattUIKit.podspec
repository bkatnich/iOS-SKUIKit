Pod::Spec.new do |s|
  s.name             = "SandKattUIKit"
  s.version          = "0.3"
  s.summary          = "SKUIKit is the base UI framework in SandKatt Solutions Inc.'s iOS application platform."

  s.description      = <<-DESC
The SKUIKit is the base UI framework in SandKatt Solutions Inc.'s iOS application platform..
                       DESC

  s.homepage         = "https://github.com/bkatnich/iOS-SKUIKit"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Britton Katnich" => "katnich@shaw.ca" }
  s.source           = { :git => "https://github.com/bkatnich/iOS-SKUIKit.git", :tag => s.version.to_s }

  s.ios.deployment_target = "11.0"
  s.source_files = "SKUIKit/**/*"

  s.swift_version = "4.0"

  s.dependency "SandKattFoundation"
  s.dependency "Hue"

end
