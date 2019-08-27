#
# Be sure to run `pod lib lint AzureCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AzureCore'
  s.version          = '0.1.0'
  s.summary          = 'AzureCore contains the types for client-side HTTP communication with REST endpoints.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
AzureCore is the baseline framework upon which all other Azure iOS clients should depend. It contains
types for client-side HTTP communication with REST endpoints.
                       DESC

  s.homepage         = 'https://github.com/Azure/azure-sdk-for-ios/AzureCore'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tjprescott' => 'trpresco@microsoft.com' }
  s.source           = { :git => 'https://github.com/Azure/azure-sdk-for-ios/AzureCore.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'AzureCore/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AzureCore' => ['AzureCore/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
