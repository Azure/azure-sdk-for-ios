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

use_frameworks!
platform :ios, '12.0'
workspace "AzureSDK"

def azure_core_pods
  pod 'MSAL', '~> 1.0.0'
end

target 'AzureCore' do
  project 'sdk/core/AzureCore/AzureCore'
  azure_core_pods
end

target 'AzureCoreTests' do
  project 'sdk/core/AzureCore/AzureCore'
  azure_core_pods
end

#target 'AzureAppConfiguration' do
#  project 'AzureAppConfiguration/AzureAppConfiguration'
#end

#target 'AzureCSComputerVision' do
#  project 'AzureCSComputerVision/AzureCSComputerVision'
#end

#target 'AzureCSTextAnalytics' do
#  project 'AzureCSTextAnalytics/AzureCSTextAnalytics'
#end

#target 'AzureStorageBlob' do
#  project 'AzureStorageBlob/AzureStorageBlob'
#end

target 'AzureSDKDemoSwift' do
  project 'examples/AzureSDKDemoSwift/AzureSDKDemoSwift'
  pod 'MSAL', '~> 1.0.0'
end

target 'AzureSDKTransferManager' do
  project 'examples/AzureSDKTransferManager/AzureSDKTransferManager'
  pod 'MSAL', '~> 1.0.0'
end
