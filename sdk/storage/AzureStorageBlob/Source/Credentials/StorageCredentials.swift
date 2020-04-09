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

/// A Storage shared access signature credential object.
public struct StorageSASCredential {
    internal let blobEndpoint: String?
    internal let queueEndpoint: String?
    internal let fileEndpoint: String?
    internal let tableEndpoint: String?
    internal let sasToken: String

    /// Create a shared access signature credential from an account-level shared access signature.
    /// - Parameters:
    ///   - connectionString: An account-level shared access signature connection string.
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
                throw HTTPResponseError.clientAuthentication(message)
            default:
                continue
            }
        }
        let invalidCS = HTTPResponseError.clientAuthentication("The connection string \(connectionString) is invalid.")
        guard let sasToken = sas else { throw invalidCS }
        self.sasToken = sasToken
        self.blobEndpoint = blob
        self.queueEndpoint = queue
        self.fileEndpoint = file
        self.tableEndpoint = table
    }

    /// Create a shared access signature credential from a container- or blob-level shared access signature.
    /// - Parameters:
    ///   - blobSasUri: A container- or blob-level shared access signature URI.
    public init(blobSasUri: String) throws {
        let invalidUri = HTTPResponseError.clientAuthentication("The URI \(blobSasUri) is invalid.")
        guard let sasUri = URL(string: blobSasUri) else { throw invalidUri }
        guard let sasToken = sasUri.query else { throw invalidUri }
        guard let scheme = sasUri.scheme else { throw invalidUri }
        guard let host = sasUri.host else { throw invalidUri }

        self.sasToken = sasToken
        self.blobEndpoint = "\(scheme)://\(host)/"
        self.queueEndpoint = nil
        self.fileEndpoint = nil
        self.tableEndpoint = nil
    }
}

/// A Storage authentication policy that relies on a shared access signature.
internal class StorageSASAuthenticationPolicy: Authenticating {
    /// The next stage in the HTTP pipeline.
    public var next: PipelineStage?

    /// A shared access signature credential.
    public let credential: StorageSASCredential

    // MARK: Initializers

    /// Create a Storage SAS-based authentication policy.
    /// - Parameter credential: A `StorageSASCredential` object.
    public init(credential: StorageSASCredential) {
        self.credential = credential
    }

    // MARK: Public Methods

    /// Authenticates an HTTP `PipelineRequest` by appending the SAS token as query parameters.
    /// - Parameters:
    ///   - request: A `PipelineRequest` object.
    ///   - completion: A completion handler that forwards the modified pipeline request.
    public func authenticate(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        let queryParams = parse(sasToken: credential.sasToken)
        request.httpRequest.add(queryParams: queryParams)
        request.httpRequest.headers[.xmsDate] = String(describing: Date(), format: .rfc1123)
        completion(request, nil)
    }

    // MARK: Private Methods

    private func parse(sasToken: String) -> [QueryParameter] {
        var queryItems = [QueryParameter]()
        for component in sasToken.components(separatedBy: "&") {
            let splitComponent = component.split(separator: "=", maxSplits: 1).map(String.init)
            let name = splitComponent.first!
            let value = splitComponent.count == 2 ? splitComponent.last : ""
            queryItems.append(name, value?.removingPercentEncoding)
        }
        return queryItems
    }
}
