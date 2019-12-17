#
#  Be sure to run `pod spec lint AzureCore.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "AzureCSTextAnalytics"
  spec.version      = "1.0.0-beta.1"
  spec.summary      = "Client library for Azure Cognitive Services Text Analytics service."
  spec.description  = <<-DESC
  Client library for Azure Cognitive Services Text Analytics service.
                   DESC
  spec.homepage     = "https://github.com/azure/azure-sdk-for-ios"
  spec.license      = "MIT"
  spec.author             = { "Microsoft" => "azuresdk@microsoft.com" }
  spec.social_media_url   = "https://twitter.com/AzureSDK"
  spec.ios.deployment_target = "12.0"
  spec.swift_version = "4.0"
  spec.source       = { :git => "https://github.com/azure/azure-sdk-for-ios.git", :tag => "#{spec.version}" }
  spec.source_files  = "**/*.swift"
end
