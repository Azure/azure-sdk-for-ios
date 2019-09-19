//
//  PipelineConfiguration.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc(AZCorePipelineConfiguration)
public class PipelineConfiguration: NSObject {

    @objc public let headersPolicy: HeadersPolicy
    @objc public let redirectPolicy: RedirectPolicy
    @objc public let retryPolicy: RetryPolicy
    @objc public let customHookPolicy: CustomHookPolicy
    @objc public let contentDecodePolicy: ContentDecodePolicy
    @objc public let loggingPolicy: NetworkTraceLoggingPolicy
    @objc public let userAgentPolicy: UserAgentPolicy
    @objc public let authenticationPolicy: AuthenticationPolicy
    @objc public let distributedTracingPolicy: DistributedTracingPolicy
    @objc public let pollingInterval: Int

    private let defaultPollingInterval = 30

    @objc public init(headersPolicy: HeadersPolicy,
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
