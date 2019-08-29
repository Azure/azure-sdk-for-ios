//
//  RedirectPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class RetryPolicy: NSObject, HttpPolicy {

    internal class RetrySettings {
        var totalRetries: Int
        var connectRetries: Int
        var readRetries: Int
        var statusRetries: Int
        var backoffFactor: Double
        var backoffMax: Int
        var retryOnMethods: [HttpMethod]
        var history: [RequestHistory]
        
        init(context: PipelineContext?, policy: RetryPolicy) {
            self.totalRetries = context?.getValue(forKey: "totalRetries") as? Int ?? policy.totalRetries
            self.connectRetries = context?.getValue(forKey: "connectRetries") as? Int ?? policy.connectRetries
            self.readRetries = context?.getValue(forKey: "readRetries") as? Int ?? policy.readRetries
            self.statusRetries = context?.getValue(forKey: "statusRetris") as? Int ?? policy.statusRetries
            self.backoffFactor = context?.getValue(forKey: "backoffFactor") as? Double ?? policy.backoffFactor
            self.backoffMax = context?.getValue(forKey: "backoffMax") as? Int ?? policy.backoffMax
            self.retryOnMethods = context?.getValue(forKey: "retryOnMethods") as? [HttpMethod] ?? policy.methodWhitelist
            self.history = [RequestHistory]()
        }
    }
    
    @objc public var next: HttpPolicy?
    
    @objc public let totalRetries: Int
    @objc public let connectRetries: Int
    @objc public let readRetries: Int
    @objc public let statusRetries: Int
    @objc public let backoffFactor: Double
    @objc public var backoffMax: Int

    private let retryOnStatusCodes: Set<Int>
    private let methodWhitelist: [HttpMethod] = [.GET, .HEAD, .PUT, .DELETE, .OPTIONS, .TRACE]
    private let respectRetryAfterHeader: Bool = true

    @objc public init(totalRetries: Int = 10, connectRetries: Int = 3, readRetries: Int = 3, statusRetries: Int = 3, backoffFactor: Double = 0.8, backoffMax: Int = 120, retryOnStatusCodes: [Int] = [Int]()) {
        self.totalRetries = totalRetries
        self.connectRetries = connectRetries
        self.readRetries = readRetries
        self.statusRetries = statusRetries
        self.backoffFactor = backoffFactor
        self.backoffMax = backoffMax
        
        var retryCodes = [Int]()
        var safeCodes = Array(stride(from: 1, to: 500, by: 1)).filter{$0 != 408}
        safeCodes.append(contentsOf: [501, 505])
        for i in 1...999 {
            if safeCodes.contains(i) { continue }
            retryCodes.append(i)
        }
        self.retryOnStatusCodes = Set<Int>(retryOnStatusCodes + retryCodes)
    }
    
    @objc static public func noRetries() -> RetryPolicy {
        return RetryPolicy(totalRetries: 0)
    }

    internal func getBackoffTime(settings: RetrySettings) -> Int {
        let consecutiveErrorsCount = settings.history.count
        guard consecutiveErrorsCount > 1 else { return 0 }
        
        let backoffValue = settings.backoffFactor * Double(truncating: pow(2, consecutiveErrorsCount - 1) as NSNumber)
        return min(settings.backoffMax, Int(backoffValue))
    }
    
    private func parse(retryAfter: String) -> Int {
        var seconds = Int(retryAfter)
        if seconds == nil {
            // TODO: parse retryAfter into retryDate
            // seconds = retryDate - currentTime
            seconds = 10
        }
        guard seconds != nil else { return 0 }
        return seconds! >= 0 ? seconds! : 0
    }
    
    private func getRetryAfter(response: PipelineResponse) -> Int {
        return self.parse(retryAfter: response.httpResponse.headers()["Retry-After"] ?? "")
    }
    
    private func sleepForRetry(response: PipelineResponse, transport: HttpTransport) -> Bool {
        let retryAfter = self.getRetryAfter(response: response)
        if retryAfter > 0 {
            transport.sleep(duration: retryAfter)
            return true
        }
        return false
    }
    
    private func sleepBackoff(settings: RetrySettings, transport: HttpTransport) {
        let backoff = self.getBackoffTime(settings: settings)
        guard backoff > 0 else { return }
        transport.sleep(duration: backoff)
    }
    
    private func sleep(settings: RetrySettings, transport: HttpTransport, response: PipelineResponse?) {
        if let response = response {
            let slept = self.sleepForRetry(response: response, transport: transport)
            if slept { return }
        }
        self.sleepBackoff(settings: settings, transport: transport)
    }
    
    private func isConnectionError(error: Error) -> Bool {
        return type(of: error) == ServiceRequestError.self
    }
    
    private func isReadError(error: Error) -> Bool {
        return type(of: error) == ServiceResponseError.self
    }
    
    private func isMethodRetryable(settings: RetrySettings, request: HttpRequest, response: HttpResponse?) -> Bool {
        let method = request.httpMethod
        if let response = response {
            let statusCode = response.statusCode()
            let allowMethods = [HttpMethod.POST, HttpMethod.PATCH]
            let allowCodes = [500, 503, 504]
            if allowMethods.contains(method) && allowCodes.contains(statusCode) { return true }
        }
        if !settings.retryOnMethods.contains(method) { return false }
        return true
    }
    
    private func isRetry(settings: RetrySettings, response: PipelineResponse) -> Bool {
        let hasRetryAfter = response.httpResponse.headers()["Retry-After"] != nil
        if hasRetryAfter && self.respectRetryAfterHeader { return true }
        if !self.isMethodRetryable(settings: settings, request: response.httpRequest, response: response.httpResponse) { return false }
        return settings.totalRetries > 0 && self.retryOnStatusCodes.contains(response.httpResponse.statusCode())
    }
    
    private func isExhausted(settings: RetrySettings) -> Bool {
        let counts = [settings.totalRetries, settings.connectRetries, settings.readRetries, settings.statusRetries].filter{$0 > 0}
        guard counts.count > 0 else { return false }
        return counts.min()! < 0
    }
    
    private func increment(settings: RetrySettings, response: PipelineResponse?, error: Error?) -> Bool {
        settings.totalRetries -= 1
        guard response?.httpResponse.statusCode() != 202 else { return false }

        if let error = error {
            if self.isConnectionError(error: error) {
                settings.connectRetries -= 1
            } else if self.isReadError(error: error) {
                settings.readRetries -= 1
            }
            if let response = response {
                settings.history.append(RequestHistory(request: response.httpRequest, response: response.httpResponse, context: response.context, error: error))
            }
        } else if let response = response {
            settings.statusRetries -= 1
            settings.history.append(RequestHistory(request: response.httpRequest, response: response.httpResponse, context: response.context, error: error))
        }
        return self.isExhausted(settings: settings)
    }
    
    private func updateContext(request: PipelineRequest, settings: RetrySettings) {
        if settings.history.count > 0 {
            request.context = request.context?.add(value: settings.history as AnyObject, forKey: "history")
        }
    }
    
    @objc public func send(request: PipelineRequest) throws -> PipelineResponse {
        var retryActive = true
        var response: PipelineResponse
        let settings = RetrySettings(context: request.context, policy: self)
        while retryActive {
            do {
                response = try self.next!.send(request: request)
                if self.isRetry(settings: settings, response: response) {
                    retryActive = self.increment(settings: settings, response: response, error: nil)
                    if retryActive {
                        self.sleep(settings: settings, transport: HttpTransport(), response: response)
                        continue
                    }
                }
                self.updateContext(request: request, settings: settings)
                return response
            } catch let error as AzureError {
                if self.isMethodRetryable(settings: settings, request: request.httpRequest, response: nil) {
                    retryActive = self.increment(settings: settings, response: nil, error: error)
                    if retryActive {
                        self.sleep(settings: settings, transport: HttpTransport(), response: nil)
                        continue
                    }
                }
                throw error
            }
        }
        throw ServiceRequestError(message: "Too many retries")
    }
}
