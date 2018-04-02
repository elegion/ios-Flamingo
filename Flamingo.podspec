Pod::Spec.new do |s|
  s.name                    = 'Flamingo'
  s.version                 = '1.2.1'
  s.summary                 = 'Swift network manager'
  s.homepage                = 'https://github.com/elegion/Flamingo'
  s.license                 = 'MIT'
  s.authors                 = { "e-Legion Ltd." => "ilya.kulebyakin@e-legion.com" }
  s.screenshots             = 'https://raw.githubusercontent.com/elegion/ios-Flamingo/master/logo.png'

  s.source                  = { :git => 'https://github.com/elegion/ios-Flamingo.git', :tag => "v#{s.version}" }

  s.ios.deployment_target   = '9.0'
  s.requires_arc            = true

  s.source_files            = 'Source'

  s.frameworks              = 'Foundation', 'UIKit'
end
