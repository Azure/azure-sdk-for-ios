Pod::Spec.new do |s|

  s.name          = 'AzureStorage'
  s.version       = '0.2.0'
  s.summary       = 'Microsoft Azure Storage client SDK for iOS.'

  s.description   = 'Microsoft Azure Storage client SDK for iOS, macOS, watchOS, tvOS.'

  s.homepage      = 'https://github.com/Azure/Azure.iOS'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = 'Microsoft Azure'

  s.source        = { :git => 'https://github.com/Azure/Azure.iOS.git', :tag => "v#{s.version}" }

  s.dependency 'AzureCore', s.version.to_s

  s.swift_version = '4.2'

  s.source_files = 'AzureStorage/Source/**/*.{swift,h,m}'

  s.ios.deployment_target     = '10.0'
  s.osx.deployment_target     = '10.12'
  s.tvos.deployment_target    = '10.0'
  s.watchos.deployment_target = '3.0'
  
end