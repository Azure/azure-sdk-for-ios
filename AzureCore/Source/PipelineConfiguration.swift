//
//  PipelineConfiguration.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc
public class PipelineConfiguration: NSObject {
    
    let headersPolicy: HeadersPolicy
    let proxyPolicy: ProxyPolicy
    let redirectPolicy: RedirectPolicy
    let retryPolicy: RetryPolicy
    let customHookPolicy: CustomHookPolicy
    let loggingPolicy: NetworkTraceLoggingPolicy
    let userAgentPolicy: UserAgentPolicy
    let authenticationPolicy: BearerTokenCredentialPolicy
    let pollingInterval: Int
    
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
