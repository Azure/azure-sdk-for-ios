Pod::Spec.new do |s|

  s.name          = 'AzureCore'
  s.version       = '0.4.4'
  s.summary       = 'Microsoft Azure client SDKs for iOS.'

  s.description   = 'Microsoft Azure client SDKs for iOS, macOS, watchOS, tvOS.'

  s.homepage      = 'https://github.com/Azure/Azure.iOS'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = 'Microsoft Azure'
  
  s.source        = { :git => 'https://github.com/Azure/Azure.iOS.git', :tag => "v#{s.version}" }

  s.dependency 'Willow', '~> 5.2'
  s.dependency 'KeychainAccess', '~> 3.2'

  s.swift_version = '5.0'

  s.source_files = 'AzureCore/Source/*.{swift,h,m}'
  
  s.ios.deployment_target     = '10.0'
  s.osx.deployment_target     = '10.12'
  s.tvos.deployment_target    = '10.0'
  s.watchos.deployment_target = '3.0'
  
end
