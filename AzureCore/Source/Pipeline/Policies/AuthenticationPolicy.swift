//
//  AuthenticationPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public protocol AuthenticationProtocol: PipelineStageProtocol {
    func authenticate(request: PipelineRequest)
}

extension AuthenticationProtocol {
    public func onRequest(_ request: inout PipelineRequest) {
        self.authenticate(request: request)
    }
}

public class BearerTokenCredentialPolicy: AuthenticationProtocol {

    public var next: PipelineStageProtocol?

    public let scopes: [String]
    public let credential: TokenCredential
    public var needNewToken: Bool {
        // TODO: Also if token expires within 300... ms?
        return (self.token == nil)
    }

    private var token: AccessToken?

    public init(credential: TokenCredential, scopes: [String]) {
        self.scopes = scopes
        self.credential = credential
        self.token = nil
    }

    public func authenticate(request: PipelineRequest) {
        if let token = self.token?.token {
            request.httpRequest.headers[.authorization] = "Bearer \(token)"
        }
    }

    public func onRequest(_ request: inout PipelineRequest) {
        if self.needNewToken {
            self.token = self.credential.getToken(scopes: self.scopes)
        }
        self.authenticate(request: request)
    }
}
