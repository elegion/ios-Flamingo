Pod::Spec.new do |s|
  s.name                    = 'Flamingo'
  s.version                 = '0.0.1'
  s.summary                 = 'Swift network manager'
  s.description             = 'Based on Alamofire, ObjectMapper and Cache'
  s.homepage                = 'https://github.com/elegion/Flamingo'
  s.license                 = 'MIT'
  s.author                  = { 'Geor Kasapidi' => 'georgy.kasapidi@e-legion.com' }
  s.source                  = { :git => 'https://github.com/elegion/Flamingo.git', :tag => "v#{s.version}" }

  s.ios.deployment_target   = '8.0'
  s.requires_arc            = true

  s.source_files            = 'Source'

  s.frameworks              = 'Foundation', 'UIKit'

  s.dependency                'Alamofire', '~> 3.4.0'
  s.dependency                'AlamofireImage', '~> 2.4.0'
  s.dependency                'Cache', '~> 1.3.0'
  s.dependency                'ObjectMapper', '~> 1.2.0'
end
