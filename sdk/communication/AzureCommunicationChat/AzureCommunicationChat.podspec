Pod::Spec.new do |spec|
  spec.name                 = "AzureCommunicationChat"
  spec.version              = "1.1.1"
  spec.summary              = "Azure Communication Chat Service client library for iOS"
  spec.homepage             = "https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationChat"
  spec.license              = { :type => 'MIT' }
  spec.author               = 'Microsoft'
  spec.source               = { :git => 'https://github.com/Azure/azure-sdk-for-ios.git', :tag => 'AzureCommunicationChat_1.1.0' }
  spec.module_name          = 'AzureCommunicationChat'
  spec.swift_version        = '5.0'

  spec.platform             = :ios, '13.0'

  spec.source_files         = 'Source/**/*.{swift,h,m}'

  spec.pod_target_xcconfig  = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]": "arm64", "DEFINES_MODULE": "YES"}

  spec.dependency             'AzureCore', '1.0.0-beta.15'
  spec.dependency             'AzureCommunicationCommon', '~> 1.2.0'
  spec.dependency             'Trouter', '0.2.0'
end
