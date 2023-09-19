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
let defaultTrouterHostname: String = "go.trouter.teams.microsoft.com/v4/a"
let defaultRegistrarHostnameAndBasePath: String = "teams.microsoft.com/registrar/prod/v3/registrations"

let eudbTrouterHostname: String = "go-eu.trouter.teams.microsoft.com/v4/a";
let eudbCountries: Set = ["europe", "france", "germany", "norway", "switzerland", "sweden"]

// GCC High gov cloud URLs
let gcchTrouterHostname: String = "go.trouter.gov.teams.microsoft.us/v4/a"
let gcchRegistrarHostnameAndBasePath: String = "registrar.gov.teams.microsoft.us"

// DoD gov cloud URLs
let dodTrouterHostname: String = "go.trouter.dod.teams.microsoft.us/v4/a"
let dodRegistrarHostnameAndBasePath: String = "registrar.dod.teams.microsoft.us"

func getTrouterSettings(token: String) throws
    -> (trouterHostname: String, registrarHostnameAndBasePath: String)
{
    let jwt = try decode(jwtToken: token)
    if let skypeId = jwt["skypeid"] as? String {
        if isGcch(id: skypeId) {
            return (gcchTrouterHostname, gcchRegistrarHostnameAndBasePath)
        }
        if isDod(id: skypeId) {
            return (dodTrouterHostname, dodRegistrarHostnameAndBasePath)
        }
    }

    if let resourceLocation = jwt["resourceLocation"] as? String {
        if eudbCountries.contains(resourceLocation) {
            return (eudbTrouterHostname, defaultRegistrarHostnameAndBasePath)
        }
    }

    return (defaultTrouterHostname, defaultRegistrarHostnameAndBasePath)
}
