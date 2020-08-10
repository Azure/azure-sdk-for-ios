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

#if canImport(AzureCore)
import AzureCore
#endif
import Foundation

struct JwtPayload: Decodable {
    var exp: UInt64
}

struct JwtTokenParser {
    static func createAccessToken(_ token: String) throws -> AccessToken {
        let payload = try decodeJwtPayload(token)
        return AccessToken(token: token, expiresOn: Date(timeIntervalSince1970: TimeInterval(payload.exp)))
    }

    static func convertFromBase64Url(_ base64Url: String) throws -> Data {
        let base64Url = base64Url.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "-")
            .appending(String(repeating: "=", count: (4 - (base64Url.count % 4)) % 4))

        let base64Data = Data(base64Encoded: base64Url)!

        guard let base64AsString = String(data: base64Data, encoding: .utf8) else {
            throw AzureError.sdk("Can't convert base64Data to base64AsString.")
        }

        guard let result = base64AsString.data(using: .utf8) else {
            throw AzureError.sdk("Can't convert base64AsString to Data")
        }

        return result
    }

    static func decodeJwtPayload(_ token: String) throws -> JwtPayload {
        let tokenParts = token.components(separatedBy: ".")

        guard tokenParts.count >= 2 else {
            throw AzureError.sdk("Token is not formatted correctly.")
        }

        let jsonData = try convertFromBase64Url(tokenParts[1])

        return try JSONDecoder().decode(JwtPayload.self, from: jsonData)
    }
}
