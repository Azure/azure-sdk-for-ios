//
//  AppConfigurationClientCredentials.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/8/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import AzureCore
import Foundation

public class AppConfigurationCredential {

    internal let endpoint: String    // endpoint
    internal let id: String          // access key id
    internal let secret: String      // access key value

    public init(connectionString: String) throws {
        let cs_comps = connectionString.components(separatedBy: ";")
        guard cs_comps.count == 3 else {
            throw HttpResponseError.clientAuthentication
        }
        var endpoint: String?
        var id: String?
        var secret: String?

        for component in connectionString.components(separatedBy: ";") {
            let comp_splits = component.split(separator: "=", maxSplits: 1)
            let key = String(comp_splits[0]).lowercased()
            let value = String(comp_splits[1])
            switch key {
            case "endpoint":
                endpoint = value
            case "id":
                id = value
            case "secret":
                secret = value
            default:
                throw HttpResponseError.clientAuthentication
            }
        }
        guard endpoint != nil && id != nil && secret != nil else {
            throw HttpResponseError.clientAuthentication
        }
        self.endpoint = endpoint!
        self.id = id!
        self.secret = secret!
    }
}

public class AppConfigurationAuthenticationPolicy: AuthenticationProtocol {

    public var next: PipelineStageProtocol?
    public let scopes: [String]
    public let credential: AppConfigurationCredential

    public init(credential: AppConfigurationCredential, scopes: [String]) {
        self.scopes = scopes
        self.credential = credential
    }

    public func authenticate(request: PipelineRequest) {
        let httpRequest = request.httpRequest
        let contentHash = [UInt8](httpRequest.body ?? Data()).sha256.base64String
        if let url = URL(string: httpRequest.url) {
            request.httpRequest.headers[HttpHeader.host] = url.host ?? ""
        }
        request.httpRequest.headers[AppConfigurationHeader.contentHash.rawValue] = contentHash
        let dateValue = request.httpRequest.headers[HttpHeader.date] ?? request.httpRequest.headers[AppConfigurationHeader.date.rawValue]
        if dateValue == nil {
            request.httpRequest.headers[AppConfigurationHeader.date.rawValue] = Date().httpFormat
        }
        sign(request: request)
    }

    private func sign(request: PipelineRequest) {
        let headers = request.httpRequest.headers
        let signedHeaderKeys = [AppConfigurationHeader.date.rawValue, HttpHeader.host.rawValue, AppConfigurationHeader.contentHash.rawValue]
        var signedHeaderValues = [String]()
        for key in signedHeaderKeys {
            if let value = headers[key] {
                signedHeaderValues.append(value)
            }
        }
        if let urlComps = URLComponents(string: request.httpRequest.url) {
            let stringToRemove = "\(urlComps.scheme!)://\(urlComps.host!)"
            let signingUrl = String(request.httpRequest.url.dropFirst(stringToRemove.count))
            if let decodedSecret = self.credential.secret.decodeBase64 {
                let stringToSign = "\(request.httpRequest.httpMethod.rawValue.uppercased(with: Locale(identifier: "en_US")))\n\(signingUrl)\n\(signedHeaderValues.joined(separator: ";"))"
                let signature = stringToSign.hmac(algorithm: .sha256, key: decodedSecret)
                request.httpRequest.headers[HttpHeader.authorization.rawValue] = "HMAC-SHA256 Credential=\(self.credential.id), SignedHeaders=\(signedHeaderKeys.joined(separator: ";")), Signature=\(signature.base64String)"
            }
        }
    }
}
