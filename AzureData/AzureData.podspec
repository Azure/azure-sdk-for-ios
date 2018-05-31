Pod::Spec.new do |spec|
  spec.name         = 'AzureData'
  spec.version      = '0.0.2'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/Azure/Azure.iOS'
  spec.authors      = { 'Microsoft Open Source' => 'opensource@microsoft.com' }
  spec.summary      = 'iOS client SDKs for Microsoft Azure'
  spec.source       = { :git => 'https://github.com/Azure/Azure.iOS/AzureData.git', :tag => 'v0.0.2' }
  spec.source_files = 'AzureData/Source/*.swift'
end
