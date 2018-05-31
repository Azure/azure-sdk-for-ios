Pod::Spec.new do |spec|
  spec.name         = 'Azure.iOS'
  spec.version      = '0.0.2'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/Azure/Azure.iOS'
  spec.authors      = { 'Microsoft Open Source' => 'opensource@microsoft.com' }
  spec.summary      = 'iOS client SDKs for Microsoft Azure'
  spec.source       = { :git => 'https://github.com/Azure/Azure.iOS.git', :tag => 'v0.0.2' }

  spec.subspec 'AzureCore' do |cs|
     cs.source_files = 'AzureCore/Source/*.swift'
  end

  spec.subspec 'AzureData' do |ds|
     ds.source_files = 'AzureData/Source/*.swift'
  end
end
