//
//  PipelineClientBase.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc open class PipelineClient: NSObject {
    
    @objc public var baseUrl: String
    @objc public var config: PipelineConfiguration
    @objc public var pipeline: Pipeline
    
    @objc public init(baseUrl: String, config: PipelineConfiguration, pipeline: Pipeline) {
        self.baseUrl = baseUrl
        self.config = config
        self.pipeline = pipeline
    }
    
    @objc public func request(method: HttpMethod, urlTemplate: String?, queryParams: [String:String]? = nil, headers: [String:String]? = nil, content: Data? = nil, formContent: [String:AnyObject]? = nil, streamContent: AnyObject? = nil) -> HttpRequest {
        let request = HttpRequest(httpMethod: method, url: self.format(urlTemplate: urlTemplate))
        
        if let queryParams = queryParams {
            request.format(queryParams: queryParams)
        }
        // TODO: apply custom headers
        return request
    }
    
    private func formatUrlSection(template: String) -> String {
        // TODO: replace {these} with their values
        // let components = template.components(separatedBy: "/")
        return template
    }
    
    private func join(base: String, stub: String) -> String {
        // TODO: Implement
        return "\(base)\(stub)"
    }
    
    private func format(urlTemplate: String?) -> String {
        var url: String
        if let urlTemplate = urlTemplate {
            url = self.formatUrlSection(template: join(base: self.baseUrl, stub: urlTemplate))
            // TODO: Some more URL parsing here...
        } else {
            url = self.baseUrl
        }
        return url
    }
}
