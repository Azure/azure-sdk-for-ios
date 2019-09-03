//
//  UrlSessionTransport.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/30/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class UrlSessionTransportDelegate: NSObject, URLSessionDelegate {
}

@objc public class UrlSessionTransport: NSObject, HttpTransport {
    
    private var session: URLSession?
    private var config: URLSessionConfiguration
    private var delegate: URLSessionDelegate
    
    @objc override public init() {
        self.config = URLSessionConfiguration.default
        self.delegate = UrlSessionTransportDelegate()
        super.init()
    }
    
    @objc public func open() {
        guard self.session == nil else { return }
        self.session = URLSession(configuration: self.config, delegate: self.delegate, delegateQueue: nil)
    }
    
    public func close() {
        self.session = nil
    }
    
    public func sleep(duration: Int) {
        Foundation.sleep(UInt32(duration))
    }
    
    public func send(request: PipelineRequest) throws -> PipelineResponse {
        self.open()
        guard let session = self.session else { return }

        var urlRequest = URLRequest(url: URL(string: request.httpRequest.url)!)
        urlRequest.httpMethod = request.httpRequest.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = request.httpRequest.headers
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            //            if let error = error {
            //                NSLog("Error: \(error.localizedDescription)")
            //                completion(nil)
            //            } else if let data = data, let httpResponse = response as? HTTPURLResponse {
            //                let decoder = JSONDecoder()
            //                do {
            //                    let settings = try decoder.decode(ConfigurationSettingsResponse.self, from: data)
            //                    completion(settings.items)
            //                } catch {
            //                    NSLog("Unexpected error: \(error).")
            //                    completion(nil)
            //                }
            //            }
        }.resume()
    }
}
