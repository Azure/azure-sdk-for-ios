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

let defaultRegistrarServiceUrl: String = "https://edge.skype.com/registrar/prod/v2/registrations"

// GCC High gov cloud URLs
let gcchRegistrarServiceUrl: String = "https://gov.teams.microsoft.us/v2/registrations"

// DoD gov cloud URLs
let dodRegistrarServiceUrl: String = "https://dod.teams.microsoft.us/v2/registrations"

func getRegistrarServiceUrl(token: String) throws -> String {
    let jwt = try decode(jwtToken: token)
    if let skypeToken = jwt["skypeid"] as? String {
        if isGcch(id: skypeToken) {
            return gcchRegistrarServiceUrl
        }
        if isDod(id: skypeToken) {
            return dodRegistrarServiceUrl
        }
    }

    return defaultRegistrarServiceUrl
}
