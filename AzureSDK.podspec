# --------------------------------------------------------------------------
#
# Copyright (c) Microsoft Corporation. All rights reserved.
#
# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the ""Software""), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#
# --------------------------------------------------------------------------

Pod::Spec.new do |s|
  s.name = 'AzureSDK'
  s.version = '0.1.0'
  s.summary = 'Azure SDK for iOS.'
  s.description = <<-DESC
  Azure SDK for iOS.
  DESC

  s.homepage = 'https://github.com/Azure/azure-sdk-for-ios'
  s.license = { :type => 'MIT',
                :file => 'LICENSE' }
  s.authors = { 'Azure SDK Mobile Team' => 'azuresdkmobileteam@microsoft.com' }

  s.ios.deployment_target = '12.0'

  s.swift_version = '5.0'
  s.source = { :git => 'https://github.com/Azure/azure-sdk-for-ios.git',
               :tag => s.version.to_s }
  s.source_files = '**/*.swift'

  # AzureCore
  s.subspec 'AzureCore' do |sp|
    sp.source_files = 'sdk/core/AzureCore/Source/**/*.{swift,h,m}'
  end

  # AzureAppConfiguration
  s.subspec 'AzureAppConfiguration' do |sp|
    sp.source_files = 'sdk/appconfiguration/AzureAppConfiguration/Source/**/*.{swift,h,m}'
  end

  # AzureCSComputerVision
  s.subspec 'AzureCSComputerVision' do |sp|
    sp.source_files = 'sdk/cognitiveservices/AzureCSComputerVision/Source/**/*.{swift,h,m}'
  end

  # AzureCSTextAnalytics
  s.subspec 'AzureCSTextAnalytics' do |sp|
    sp.source_files = 'sdk/textanalytics/AzureCSTextAnalytics/Source/**/*.{swift,h,m}'
  end

  # AzureStorageBlob
  s.subspec 'AzureStorageBlob' do |sp|
    sp.source_files = 'sdk/storage/AzureStorageBlob/Source/**/*.{swift,h,m}'
    sp.dependency 'MSAL', '~> 1.0.0'
  end

  # AzureSDKDemoSwift
  s.subspec 'AzureSDKDemoSwift' do |sp|
    sp.source_files = 'examples/AzureSDKDemoSwift/Source/**/*.{swift,h,m}'
  end

  # AzureSDKTransferManager
  s.subspec 'AzureSDKTransferManager' do |sp|
    sp.source_files = 'examples/AzureSDKTransferManager/Source/**/*.{swift,h,m}'
  end
end
