//
//  TrouterSettings.swift
//  AzureCommunicationSignaling
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import TrouterModulePrivate

// swiftlint:disable force_cast
var defaultRegistrationData = TrouterUrlRegistrationData.create(
    withApplicationId: "AcsiOS_test",
    registrationId: nil,
    platform: "SPOOL",
    platformUiVersion: "0.0.0",
    templateKey: "AcsiOS_Chat_test_1.1",
    productContext: nil,
    context: ""
) as! TrouterUrlRegistrationData
// swiftlint:enable force_cast

var defaultClientVersion = "1.0.0"
var defaultTrouterHostname = "go.trouter-int.skype.net/v4/a"
var defaultRegistrarHostnameAndBasePath = "edge.skype.net/registrar/testenv"

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
