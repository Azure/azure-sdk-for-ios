Pod::Spec.new do |s|

  s.name          = 'AzureAuth'
  s.version       = '0.1.7'
  s.summary       = 'Microsoft Azure App Service Auth client SDK for iOS.'

  s.description   = 'Microsoft Azure App Service Auth client SDK for iOS, macOS, watchOS, tvOS.'

  s.homepage      = 'https://github.com/Azure/Azure.iOS'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = 'Microsoft Azure'

  s.source        = { :git => 'https://github.com/Azure/Azure.iOS.git', :tag => "v#{s.version}" }

  s.dependency 'AzureCore', s.version.to_s

  s.swift_version = '4.1'

  s.source_files = 'AzureAuth/Source/**/*.{swift,h,m}'

  s.ios.deployment_target     = '10.0'
  s.osx.deployment_target     = '10.12'
  s.tvos.deployment_target    = '10.0'
  s.watchos.deployment_target = '3.0'
  
end