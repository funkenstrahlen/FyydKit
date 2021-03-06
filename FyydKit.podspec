Pod::Spec.new do |s|
  s.name         = "FyydKit"
  s.version      = "0.1"
  s.summary      = "Swift implementation of the fyyd API"
  s.description  = <<-DESC
    Swift implementation of the fyyd API.
  DESC
  s.homepage     = "https://github.com/funkenstrahlen/FyydKit.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Stefan Trauth" => "mail@stefantrauth.de" }
  s.social_media_url   = ""
  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.12"
  s.watchos.deployment_target = "4.0"
  s.tvos.deployment_target = "11.0"
  s.source       = { :git => "https://github.com/funkenstrahlen/FyydKit.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation", "SafariServices"
  s.dependency "Alamofire"
  s.dependency "CodableAlamofire"
end
