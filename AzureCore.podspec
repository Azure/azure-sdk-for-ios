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
    s.name = 'AzureCore'
    s.version = '1.0.0-beta.5'
    s.summary = 'Azure core client library for iOS'
    s.description = <<~DESC
      This is the core framework for the Azure SDK for iOS, containing the HTTP
      pipeline, as well as a shared set of components that are used across all
      client libraries, including pipeline policies, error types, type aliases,
      an XML Codable implementation, and a logging system. As an end user, you
      don't need to manually install AzureCore because it will be installed
      automatically when you install other SDK libraries. If you are a client
      library developer, please reference the AzureCommunicationChat library as
      an example of how to use the shared AzureCore components in your client
      library.
    DESC
  
    s.homepage = 'https://github.com/Azure/azure-sdk-for-ios'
    s.license = { :type => 'MIT',
                  :file => 'LICENSE' }
    s.authors = { 'Azure SDK Mobile Team' => 'azuresdkmobileteam@microsoft.com' }
  
    s.ios.deployment_target = '12.0'
  
    s.swift_version = '5.0'
  
    s.source = { :git => 'https://github.com/Azure/azure-sdk-for-ios.git',
                 :tag => '1.0.0-beta.5' }
    s.source_files = 'sdk/core/AzureCore/Source/**/*.{swift,h,m}'
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  end
