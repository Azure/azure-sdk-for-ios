//
//  TrouterSettings.swift
//  AzureCommunicationSignaling
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import TrouterClientIos

// swiftlint:disable force_cast
var defaultRegistrationData = TrouterUrlRegistrationData.create(
    withApplicationId: "AcsiOS",
    registrationId: nil,
    platform: "SPOOL",
    platformUiVersion: "0.0.0",
    templateKey: "AcsiOS_Chat_1.1",
    productContext: nil,
    context: ""
) as! TrouterUrlRegistrationData
// swiftlint:enable force_cast

var defaultClientVersion = "1.0.0"
var defaultTrouterHostname = "go.trouter.skype.com/v4/a"
var defaultRegistrarHostnameAndBasePath = "edge.skype.com/registrar/prod"

func createRegistrationData() -> TrouterUrlRegistrationData {
    return defaultRegistrationData
}

func getClientVersion() -> String {
    return defaultClientVersion
}

func getTrouterHostname() -> String {
    return defaultTrouterHostname
}

func getRegistrarHostnameAndBasePath() -> String {
    return defaultRegistrarHostnameAndBasePath
}
