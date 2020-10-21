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
    s.version = '1.0.0-beta.4'
    s.summary = 'Azure Communication Calling SDK for iOS'
    s.description = <<-DESC
    Azure Communication Calling SDK for iOS
    DESC
  
    s.homepage = 'https://github.com/Azure/azure-sdk-for-ios'
    s.license = { :type => 'Commercial',
                  :file => 'EULA.txt' }
    s.authors = { 'Azure SDK Mobile Team' => 'azuresdkmobileteam@microsoft.com' }
  
    s.ios.deployment_target = '12.0'
    s.ios.vendored_frameworks = "AzureCommunicationCalling.framework"

    s.swift_version = '5.0'
  
    s.source = { :http => 'https://github.com/Azure/Communication/releases/download/v1.0.0-beta.4/azurecommunicationcalling.framework-1.0.0-beta.4.zip' }
    s.source_files = 'Headers/*.h'
    s.public_header_files = "Headers/*.h"
    s.dependency 'AzureCore', '~> 1.0.0-beta.2'
    s.dependency 'AzureCommunication', '~> 1.0.0-beta.2'

  end
