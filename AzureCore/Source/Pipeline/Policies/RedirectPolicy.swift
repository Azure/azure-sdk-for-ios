//
//  RedirectPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class RedirectPolicy: NSObject, HttpPolicy {

    @objc public var next: HttpPolicy?
    
    @objc public let totalRetries: Int = 10
    @objc public let connectRetries: Int = 3
    @objc public let readRetries: Int = 3
    @objc public let statusRetries: Int = 3
    @objc public let backoffFactor: Double = 0.8
    @objc public var backoffMax: Int = 120
    
    private let safeCodes: [Int]
    private let retryCodes: [Int]

    @objc public init(totalRetries: NSNumber?, connectRetries: NSNumber?, readRetries: NSNumber?, statusRetries: NSNumber?, statusRetries: NSNumber?, backoffFactor: NSDecimalNumber?, backoffMax: NSNumber?) {
        
    }

    
//        safe_codes = [i for i in range(500) if i != 408] + [501, 505]
//        retry_codes = [i for i in range(999) if i not in safe_codes]
//        status_codes = kwargs.pop('retry_on_status_codes', [])
//        self._retry_on_status_codes = set(status_codes + retry_codes)
//        self._method_whitelist = frozenset(['HEAD', 'GET', 'PUT', 'DELETE', 'OPTIONS', 'TRACE'])
//        self._respect_retry_after_header = True
//        super(RetryPolicy, self).__init__()

    
    @objc public func send(request: PipelineRequest) throws -> PipelineResponse {
//        var retryable = true
//        let redirectSettings = self.configureRedirects(request.context)
//        while retryable {
//            let response = self.next?.send(request: request)
//            let redirectLocation = self.getRedirectLocation(response: response)
//            if (redirectLocation != nil && redirectSettings["allow"]) {
//                retryable = self.increment(redirectSettings: redirectSettings, response: response, redirectLocation: redirectLocation)
//                request.httpRequest = response!.httpRequest
//                continue
//            }
//            return response
//        }
    }
}
