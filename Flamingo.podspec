Pod::Spec.new do |s|
  s.name                    = 'Flamingo'
  s.version                 = '0.2.1'
  s.summary                 = 'Swift network manager'
  s.description             = 'Based on Alamofire, ObjectMapper and Cache'
  s.homepage                = 'https://github.com/elegion/Flamingo'
  s.license                 = 'MIT'
  s.screenshots             = 'https://raw.githubusercontent.com/elegion/ios-Flamingo/master/logo.png'

  s.author                  = { 'Geor Kasapidi' => 'georgy.kasapidi@e-legion.com' }
  s.source                  = { :git => 'https://github.com/elegion/ios-Flamingo.git', :tag => "v#{s.version}" }

  s.ios.deployment_target   = '9.0'
  s.requires_arc            = true

  s.source_files            = 'Source'

  s.frameworks              = 'Foundation', 'UIKit'

  s.dependency                'Alamofire', '~> 4.0.1'
  s.dependency                'Cache', '~> 2.1.1'
  s.dependency                'ObjectMapper', '~> 2.2.1'
end
