Pod::Spec.new do |s|
  s.name                    = 'Flamingo'
  s.version                 = '0.1.2'
  s.summary                 = 'Swift network manager'
  s.description             = 'Based on Alamofire, ObjectMapper and Cache'
  s.homepage                = 'https://github.com/elegion/Flamingo'
  s.license                 = 'MIT'
  s.screenshots             = 'https://raw.githubusercontent.com/elegion/ios-Flamingo/master/logo.png'

  s.author                  = { 'Geor Kasapidi' => 'georgy.kasapidi@e-legion.com' }
  s.source                  = { :git => 'https://github.com/elegion/ios-Flamingo.git', :tag => "v#{s.version}" }

  s.ios.deployment_target   = '8.0'
  s.requires_arc            = true

  s.source_files            = 'Source'

  s.frameworks              = 'Foundation', 'UIKit'

  s.dependency                'Alamofire', '~> 3.4.2'
  s.dependency                'Cache', '~> 1.5.1'
  s.dependency                'ObjectMapper', '~> 1.4.0'
end
