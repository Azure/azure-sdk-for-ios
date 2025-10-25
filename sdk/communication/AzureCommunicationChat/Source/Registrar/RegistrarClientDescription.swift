// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import Foundation

/// Client description for set registration requests.
internal struct RegistrarClientDescription: Codable {
    /// The AppId.
    internal let appId: String
    /// IETF Language tags.
    internal let languageId: String
    /// Client platform.
    internal let platform: String
    /// Platform ID.
    internal let platformUIVersion: String
    /// Template key.
    internal let templateKey: String
    /// Template version.
    internal let templateVersion: String?
    /// Crypto key.
    internal let aesKey: String
    /// Auth key.
    internal let authKey: String
    /// Crypto method.
    internal let cryptoMethod: String

    internal init(
        templateVersion: String? = nil,
        aesKey: String,
        authKey: String,
        cryptoMethod: String
    ) {
        self.appId = "AcsIos"
        self.languageId = ""
        self.platform = "iOS"
        self.platformUIVersion = "3619/0.0.0.0/"
        self.templateKey = "AcsIos.AcsNotify_Chat_3.0"
        self.templateVersion = templateVersion
        self.aesKey = aesKey
        self.authKey = authKey
        self.cryptoMethod = cryptoMethod
    }
}
