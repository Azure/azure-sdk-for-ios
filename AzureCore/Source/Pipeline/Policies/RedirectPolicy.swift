//
//  RetryPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class RedirectPolicy: NSObject, HttpPolicy {

    internal class RedirectSettings {
        var allowRedirects: Bool
        var maxRedirects: Int
        var history: [RequestHistory]
        
        init(context: PipelineContext?, policy: RedirectPolicy) {
            self.allowRedirects = context?.getValue(forKey: "allowRedirects") as? Bool ?? policy.allowRedirects
            self.maxRedirects = context?.getValue(forKey: "maxRedirects") as? Int ?? policy.maxRedirects
            self.history = [RequestHistory]()
        }
    }

    
    @objc public var next: PipelineSendable?
    
    private var allowRedirects: Bool
    private var maxRedirects: Int
    
    private let redirectHeadersBlacklist: [HttpHeader] = [.authorization]
    private let redirectStatusCodes: [Int] = [300, 301, 302, 303, 307, 308]
    
    private var removeHeadersOnRedirect: [HttpHeader]
    private var redirectOnStatusCodes: [Int]
    
    @objc public init(allowRedirects: Bool = true, maxRedirects: Int = 30, /* removeHeadersOnRedirect: [HttpHeaderType]?,*/ redirectOnStatusCodes: [Int]? = nil) {
        self.allowRedirects = allowRedirects
        self.maxRedirects = maxRedirects

        self.removeHeadersOnRedirect = self.redirectHeadersBlacklist
        // TODO: Fix this...
//        if let removeHeaders = removeHeadersOnRedirect {
//            self.removeHeadersOnRedirect.append(contentsOf: removeHeaders)
//        }
        self.redirectOnStatusCodes = self.redirectStatusCodes
        if let redirect = redirectOnStatusCodes {
            self.redirectOnStatusCodes.append(contentsOf: redirect)
        }
    }
    
    @objc public static func noRedirect() -> RedirectPolicy {
        return RedirectPolicy(allowRedirects: false)
    }
    
    private func getRedirectLocation(response: PipelineResponse) -> String? {
        let statusCode = response.httpResponse.statusCode
        let method = response.httpRequest.httpMethod
        if [301, 302].contains(statusCode) {
            if [HttpMethod.GET, HttpMethod.HEAD].contains(method) {
                return response.httpResponse.headers[HttpHeader.retryAfter] as String?
            }
            return nil
        }
        if self.redirectOnStatusCodes.contains(statusCode) {
            return response.httpResponse.headers[HttpHeader.retryAfter] as String?
        }
        return nil
    }
    
    private func increment(settings: RedirectSettings, response: PipelineResponse, location: String) -> Bool {
        settings.maxRedirects -= 1
        settings.history.append(RequestHistory(request: response.httpRequest, response: response.httpResponse, context: response.context, error: nil))
        
        response.httpRequest.url = location
        if response.httpResponse.statusCode == 303 {
            response.httpRequest.httpMethod = .GET
        }
        for nonRedirectHeader in self.removeHeadersOnRedirect {
            response.httpRequest.headers.removeValue(forKey: nonRedirectHeader.rawValue)
        }
        return settings.maxRedirects >= 0
    }
    
    @objc public func send(request: PipelineRequest) throws -> PipelineResponse {
        var retryable = true
        let settings = RedirectSettings(context: request.context, policy: self)
        var response: PipelineResponse
        while retryable {
            response = try self.next!.send(request: request)
            if let redirectLocation = self.getRedirectLocation(response: response) {
                retryable = self.increment(settings: settings, response: response, location: redirectLocation)
                request.httpRequest = response.httpRequest
                continue
            }
            return response
        }
        throw TooManyRedirectsError(message: settings.history.description, response: nil)
    }
}
