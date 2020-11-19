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
    s.name = 'AzureCommunicationCalling'
    s.version = '1.0.0-beta.5'
    s.summary = 'Azure Communication Calling Service client library for iOS'
    s.description = <<~DESC
      This package contains the Calling client library for Azure Communication
      Services.
    DESC

    s.homepage = 'https://github.com/Azure/azure-sdk-for-ios'
    s.license = { :type => 'Commercial',
                  :file => 'EULA.txt' }
    s.authors = { 'Azure SDK Mobile Team' => 'azuresdkmobileteam@microsoft.com' }

    s.platform = :ios, '12.0'

    s.swift_version = '5.0'

    s.source = { :http => 'https://github.com/Azure/Communication/releases/download/v1.0.0-beta.5/AzureCommunicationCalling-1.0.0-beta.5.zip' }
    s.source_files = 'AzureCommunicationCalling.framework/Headers/*.h'
    s.public_header_files = 'AzureCommunicationCalling.framework/Headers/*.h'
    s.vendored_frameworks = 'AzureCommunicationCalling.framework'
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

    s.dependency 'AzureCommunication', '~> 1.0.0-beta.5'
  end
