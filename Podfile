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
workspace 'AzureSDK'

# update with local repo location
$dvr_path = '~/repos/DVR'
$use_local_dvr = false

target 'AzureTemplate' do
  project 'sdk/template/AzureTemplate/AzureTemplate'
end

target 'AzureCommunicationCommon' do
  project 'sdk/communication/AzureCommunicationCommon/AzureCommunicationCommon'

  target 'AzureCommunicationCommonTests' do
    inherit! :search_paths
  end
end

target 'AzureCommunicationChat' do
  project 'sdk/communication/AzureCommunicationChat/AzureCommunicationChat'
  pod 'Trouter', '0.2.0'

  target 'AzureCommunicationChatTests' do
    inherit! :search_paths
    pod 'OHHTTPStubs/Swift'
    pod 'Trouter', '0.2.0'
    if $use_local_dvr
        pod 'DVR', :path => $dvr_path
    else
        pod 'DVR', :git => 'https://github.com/tjprescott/DVR.git'
    end
  end
  
  target 'AzureCommunicationChatUnitTests' do
    inherit! :search_paths
    pod 'OHHTTPStubs/Swift'
    pod 'Trouter', '0.2.0'
    if $use_local_dvr
        pod 'DVR', :path => $dvr_path
    else
        pod 'DVR', :git => 'https://github.com/tjprescott/DVR.git'
    end
  end
end

target 'AzureCore' do
  project 'sdk/core/AzureCore/AzureCore'

  target 'AzureCoreTests' do
    inherit! :search_paths
  end
end

target 'AzureIdentity' do
  project 'sdk/identity/AzureIdentity/AzureIdentity'
  pod 'MSAL', '1.1.15'

  target 'AzureIdentityTests' do
    inherit! :search_paths
    pod 'MSAL', '1.1.15'
  end
end

target 'AzureTest' do
  project 'sdk/test/AzureTest/AzureTest'

  if $use_local_dvr
    pod 'DVR', :path => $dvr_path
  else
    pod 'DVR', :git => 'https://github.com/tjprescott/DVR.git'
  end

  target 'AzureTestTests' do
    inherit! :search_paths
    if $use_local_dvr
      pod 'DVR', :path => $dvr_path
    else
      pod 'DVR', :git => 'https://github.com/tjprescott/DVR.git'
    end
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end
