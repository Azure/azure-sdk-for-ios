//
//  PipelineConfiguration.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class PipelineConfiguration: NSObject {
    
    @objc public let headersPolicy: HeadersPolicy
    @objc public let proxyPolicy: ProxyPolicy
    @objc public let redirectPolicy: RedirectPolicy
    @objc public let retryPolicy: RetryPolicy
    @objc public let customHookPolicy: CustomHookPolicy
    @objc public let loggingPolicy: NetworkTraceLoggingPolicy
    @objc public let userAgentPolicy: UserAgentPolicy
    @objc public let authenticationPolicy: BearerTokenCredentialPolicy
    @objc public let pollingInterval: Int
    
    private let defaultPollingInterval = 30
    
    @objc public init(headersPolicy: HeadersPolicy, proxyPolicy: ProxyPolicy, redirectPolicy: RedirectPolicy, retryPolicy: RetryPolicy, customHookPolicy: CustomHookPolicy, loggingPolicy: NetworkTraceLoggingPolicy, userAgentPolicy: UserAgentPolicy, authenticationPolicy: BearerTokenCredentialPolicy, pollingInterval: Int = -1) {
        self.headersPolicy = headersPolicy
        self.proxyPolicy = proxyPolicy
        self.redirectPolicy = redirectPolicy
        self.retryPolicy = retryPolicy
        self.customHookPolicy = customHookPolicy
        self.loggingPolicy = loggingPolicy
        self.userAgentPolicy = userAgentPolicy
        self.authenticationPolicy = authenticationPolicy
        self.pollingInterval = pollingInterval > 0 ? pollingInterval : self.defaultPollingInterval
    }
}
