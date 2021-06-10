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

struct JwtPayload: Decodable {
    var exp: UInt64
}

/**
 Utility for Handling Access Tokens.
 */
enum JwtTokenParser {
    /**
     Create `AccessToken` object from token string

     - Parameter token: Token string

     - Returns: A new `AccessToken` instance
     */
    static func createAccessToken(_ token: String) throws -> CommunicationAccessToken {
        let payload = try decodeJwtPayload(token)
        return CommunicationAccessToken(token: token, expiresOn: Date(timeIntervalSince1970: TimeInterval(payload.exp)))
    }

    /**
     Helper function that converts base64 url to `Data` object
     - Parameter base64Url: Url string to convert

     - Throws: `NSError` if we can't convert base64Data to base64String or if we can't convert base64String to Data.

     - Returns: Data representation of url
     */
    static func convertFromBase64Url(_ base64Url: String) throws -> Data {
        let base64Url = base64Url.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "-")
            .appending(String(repeating: "=", count: (4 - (base64Url.count % 4)) % 4))

        guard let base64Data = Data(base64Encoded: base64Url),
            let base64AsString = String(data: base64Data, encoding: .utf8)
        else {
            throw NSError(
                domain: "AzureCommunicationCommon.JwtTokenParser.convertFromBase64Url",
                code: 0,
                userInfo: ["message": "Can't convert base64Data to base64AsString."]
            )
        }

        guard let result = base64AsString.data(using: .utf8) else {
            throw NSError(
                domain: "AzureCommunicationCommon.JwtTokenParser.convertFromBase64Url",
                code: 0,
                userInfo: ["message": "Can't convert base64AsString to Data"]
            )
        }

        return result
    }

    /**
     Helper function validates the token and returns a `JwtPayload`

     - Parameter token: Token string

     - Throws: `NSError` if the token does not follow JWT standards.

     - Returns: `JwtPayload`
     */
    static func decodeJwtPayload(_ token: String) throws -> JwtPayload {
        let tokenParts = token.components(separatedBy: ".")

        guard tokenParts.count >= 2 else {
            throw NSError(
                domain: "AzureCommunicationCommon.JwtTokenParser.decodeJwtPayload",
                code: 0,
                userInfo: ["message": "Token is not formatted correctly."]
            )
        }

        let jsonData = try convertFromBase64Url(tokenParts[1])

        return try JSONDecoder().decode(JwtPayload.self, from: jsonData)
    }
}
