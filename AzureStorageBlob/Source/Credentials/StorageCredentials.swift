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

import AzureCore
import Foundation

public class StorageOAuthCredential: TokenCredential {
    public func getToken(forScopes _: [String]) -> AccessToken? {
        guard let authUrl = URL(string: "https://login.microsoftonline.com/{tenant}/oauth2/token") else { return nil }
        let tokenLife = 15 // in minutes
        if let expiration = Calendar.current.date(byAdding: .minute, value: tokenLife, to: Date()) {
            // TODO: Token retrieval implementation
            let expirationInt = Int(expiration.timeIntervalSinceReferenceDate)
            var token = ""
            URLSession.shared.dataTask(with: authUrl) { _, _, error in
                if error != nil {
                    print(error as Any)
                }
            }
            return AccessToken(token: token, expiresOn: expirationInt)
        }
        return nil
    }
}

public class StorageSASCredential {
    internal let blobEndpoint: String?
    internal let queueEndpoint: String?
    internal let fileEndpoint: String?
    internal let tableEndpoint: String?
    internal let sasToken: String

    public init(connectionString: String) throws {
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
        blobEndpoint = blob
        queueEndpoint = queue
        fileEndpoint = file
        tableEndpoint = table
    }
}

public class StorageSASAuthenticationPolicy: AuthenticationProtocol {
    public var next: PipelineStageProtocol?
    public let credential: StorageSASCredential

    public init(credential: StorageSASCredential) {
        self.credential = credential
    }

    private func parse(sasToken: String) -> [String: String] {
        var queryItems = [String: String]()
        for component in sasToken.components(separatedBy: "&") {
            let splitComponent = component.split(separator: "=", maxSplits: 1).map(String.init)
            let name = splitComponent.first!
            let value = splitComponent.count == 2 ? splitComponent.last : ""
            queryItems[name] = value?.removingPercentEncoding
        }
        return queryItems
    }

    public func authenticate(request: PipelineRequest) {
        let queryParams = parse(sasToken: credential.sasToken)
        request.httpRequest.format(queryParams: queryParams)
        request.httpRequest.headers["x-ms-date"] = Date().httpFormat
    }
}
