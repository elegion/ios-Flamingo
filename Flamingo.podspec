Pod::Spec.new do |s|
  s.name                    = File.basename(__FILE__).chomp(".podspec")
  s.version                 = '2.2.5'
  s.summary                 = 'Swift network manager'
  s.homepage                = 'https://github.com/elegion/Flamingo'
  s.license                 = 'MIT'
  s.authors                 = { "e-Legion Ltd." => "ilya.kulebyakin@e-legion.com" }
  s.screenshots             = 'https://raw.githubusercontent.com/elegion/ios-Flamingo/master/logo.png'
  s.swift_versions          = '5.0'

  s.source                  = { :git => 'https://github.com/elegion/ios-Flamingo.git', :tag => "v#{s.version}" }

  s.ios.deployment_target   = '9.0'

  s.source_files            = 'Source'
end
