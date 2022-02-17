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
import Trouter

let defaultRegistrationData: TrouterUrlRegistrationData? = TrouterUrlRegistrationData.create(
    withApplicationId: "AcsiOS",
    registrationId: nil,
    platform: "SPOOL",
    platformUiVersion: "0.0.0",
    templateKey: "AcsiOS_Chat_1.3",
    productContext: nil,
    context: ""
) as? TrouterUrlRegistrationData

let defaultClientVersion: String = "1.0.0"
let defaultTrouterHostname: String = "go.trouter.skype.com/v4/a"
let defaultRegistrarHostnameAndBasePath: String = "edge.skype.com/registrar/prod"

// GCC High gov cloud URLs
let gcchTrouterHostname: String = "go.trouter.gov.teams.microsoft.us/v4/a"
let gcchRegistrarHostnameAndBasePath: String = "registrar.gov.teams.microsoft.us"

// DoD gov cloud URLs
let dodTrouterHostname: String = "go.trouter.dod.teams.microsoft.us/v4/a"
let dodRegistrarHostnameAndBasePath: String = "registrar.dod.teams.microsoft.us"

func getTrouterSettings(token: String) throws
    -> (trouterHostname: String, registrarHostnameAndBasePath: String) {
    let jwt = try decode(jwtToken: token)
    if let skypeToken = jwt["skypeid"] as? String {
        if isGcch(id: skypeToken) {
            return (gcchTrouterHostname, gcchRegistrarHostnameAndBasePath)
        }
        if isDod(id: skypeToken) {
            return (dodTrouterHostname, dodRegistrarHostnameAndBasePath)
        }
    }

    return (defaultTrouterHostname, defaultRegistrarHostnameAndBasePath)
}

func decode(jwtToken jwt: String) throws -> [String: Any] {
    enum DecodeErrors: Error {
        case badToken
        case other
    }

    func base64Decode(_ base64: String) throws -> Data {
        let base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        guard let decoded = Data(base64Encoded: padded) else {
            throw DecodeErrors.badToken
        }
        return decoded
    }

    func decodeJWTPart(_ value: String) throws -> [String: Any] {
        let bodyData = try base64Decode(value)
        let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
        guard let payload = json as? [String: Any] else {
            throw DecodeErrors.other
        }
        return payload
    }

    let segments = jwt.components(separatedBy: ".")
    return try decodeJWTPart(segments[1])
}

func isDod(id: String) -> Bool {
    let gcchTeamsUserPrefix = "dod:"
    let gcchAcsUserPrefix = "dod-acs:"
    return (id.starts(with: gcchTeamsUserPrefix) || id.starts(with: gcchAcsUserPrefix))
}

func isGcch(id: String) -> Bool {
    let gcchTeamsUserPrefix = "gcch:"
    let gcchAcsUserPrefix = "gcch-acs:"
    return (id.starts(with: gcchTeamsUserPrefix) || id.starts(with: gcchAcsUserPrefix))
}
