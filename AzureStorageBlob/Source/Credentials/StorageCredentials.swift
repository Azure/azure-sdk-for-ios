//
//  StorageAuthenticationPolicy.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 9/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import Foundation

public class StorageOAuthCredential: TokenCredential {

    public func getToken(forScopes scopes: [String]) -> AccessToken? {
        guard let authUrl = URL(string: "https://login.microsoftonline.com/{tenant}/oauth2/token") else { return nil }
        let tokenLife = 15 // in minutes
        if let expiration = Calendar.current.date(byAdding: .minute, value: tokenLife, to: Date()) {
            // TODO: Token retrieval implementation
            let expirationInt = Int(expiration.timeIntervalSinceReferenceDate)
            URLSession.shared.dataTask(with: authUrl) { data, response, error in
                let test = "best"
            }
            return AccessToken(token: "banoodle", expiresOn: expirationInt)
        }
        return nil
    }
}

public class StorageSASCredential {

    internal let accountName: String
    internal let blobEndpoint: String?
    internal let queueEndpoint: String?
    internal let fileEndpoint: String?
    internal let tableEndpoint: String?
    internal let sasToken: String

    public init(accountName: String, connectionString: String) throws {
        self.accountName = accountName

        // temp variables
        var blob: String?
        var queue: String?
        var file: String?
        var table: String?
        var sas: String?

        for component in connectionString.components(separatedBy: ";") {
            let compSplits = component.split(separator: "=", maxSplits: 1)
            let key = String(compSplits[0]).lowercased()
            let value = String(compSplits[1])

            switch key {
            case "blobendpoint":
                blob = value
            case "queueendpoint":
                queue = value
            case "fileendpoint":
                file = value
            case "tableendpoint":
                table = value
            case "sharedaccesssignature":
                sas = value
            case "accountkey":
                let message = """
                    Form of connection string with 'AccountKey' is not allowed. Provide a SAS-based
                    connection string.
                """
                throw HttpResponseError.clientAuthentication(message)
            default:
                continue
            }
        }
        let invalidCS = HttpResponseError.clientAuthentication("The connection string \(connectionString) is invalid.")
        guard let sasToken = sas else { throw invalidCS }
        self.sasToken = sasToken
        self.blobEndpoint = blob
        self.queueEndpoint = queue
        self.fileEndpoint = file
        self.tableEndpoint = table
    }
}

public class StorageSASAuthenticationPolicy: AuthenticationProtocol {

    public var next: PipelineStageProtocol?
    public let credential: StorageSASCredential

    public init(credential: StorageSASCredential) {
        self.credential = credential
    }

    public func authenticate(request: PipelineRequest) {
        let sasToken = self.credential.sasToken
        let queryParams = sasToken.parseQueryString()
        request.httpRequest.format(queryParams: queryParams)
    }
}
