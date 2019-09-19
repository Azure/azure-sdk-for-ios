//
//  PipelineConfiguration.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class PipelineConfiguration {

    public let headersPolicy: HeadersPolicy
    public let redirectPolicy: RedirectPolicy
    public let retryPolicy: RetryPolicy
    public let customHookPolicy: CustomHookPolicy
    public let contentDecodePolicy: ContentDecodePolicy
    public let loggingPolicy: NetworkTraceLoggingPolicy
    public let userAgentPolicy: UserAgentPolicy
    public let authenticationPolicy: AuthenticationPolicy
    public let distributedTracingPolicy: DistributedTracingPolicy
    public let pollingInterval: Int

    private let defaultPollingInterval = 30

    public init(headersPolicy: HeadersPolicy,
                redirectPolicy: RedirectPolicy,
                retryPolicy: RetryPolicy,
                customHookPolicy: CustomHookPolicy,
                contentDecodePolicy: ContentDecodePolicy,
                loggingPolicy: NetworkTraceLoggingPolicy,
                userAgentPolicy: UserAgentPolicy,
                authenticationPolicy: AuthenticationPolicy,
                distributedTracingPolicy: DistributedTracingPolicy,
                pollingInterval: Int = -1) {
        self.headersPolicy = headersPolicy
        self.redirectPolicy = redirectPolicy
        self.retryPolicy = retryPolicy
        self.customHookPolicy = customHookPolicy
        self.contentDecodePolicy = contentDecodePolicy
        self.loggingPolicy = loggingPolicy
        self.userAgentPolicy = userAgentPolicy
        self.authenticationPolicy = authenticationPolicy
        self.distributedTracingPolicy = distributedTracingPolicy
        self.pollingInterval = pollingInterval > 0 ? pollingInterval : self.defaultPollingInterval
    }
}
