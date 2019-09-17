//
//  UrlSessionTransport.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/30/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import os
import Foundation

@objc public enum UrlSessionTransportError: Int, Error {
    case invalidSession
}

@objc public class UrlSessionTransport: NSObject, HttpTransport {

    public var next: PipelineSendable? = nil
    
    private var session: URLSession?
    private var config: URLSessionConfiguration
    
    @objc override public init() {
        self.config = URLSessionConfiguration.default
    }
    
    @objc public func open() {
        guard self.session == nil else { return }
        self.session = URLSession(configuration: self.config, delegate: nil, delegateQueue: nil)
    }
    
    @objc public func close() {
        self.session = nil
    }
    
    @objc public func sleep(duration: Int) {
        Foundation.sleep(UInt32(duration))
    }
    
    @objc public func send(request: PipelineRequest) throws -> PipelineResponse {
        self.open()
        guard let session = self.session else {
            throw UrlSessionTransportError.invalidSession
        }

        var urlRequest = URLRequest(url: URL(string: request.httpRequest.url)!)
        urlRequest.httpMethod = request.httpRequest.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = request.httpRequest.headers
        let semaphore = DispatchSemaphore(value: 0)
        var httpResponse = UrlHttpResponse(request: request.httpRequest, response: nil)
        session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                os_log("Error: %@", type: .error, error.localizedDescription)
            } else if let data = data, let rawResponse = response as? HTTPURLResponse {
                httpResponse = UrlHttpResponse(request: request.httpRequest, response: rawResponse)
                httpResponse.data = data
            }
            semaphore.signal()
        }.resume()
        
        semaphore.wait()
        return PipelineResponse(request: request.httpRequest, response: httpResponse, context: request.context)
    }
}
