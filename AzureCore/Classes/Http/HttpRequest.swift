//
//  HttpRequest.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc
public class HttpRequest: NSObject {
    private static let serialVersionID = 6338479743058758810
    
    @objc var httpMethod: HttpMethod
    @objc var url: URL
    @objc var headers: HttpHeaders
    @objc var body: Data?
    
    @objc convenience public init(httpMethod: HttpMethod, url: URL) {
        self.init(httpMethod: httpMethod, url: url, headers: HttpHeaders(), body: nil)
    }
    
    @objc public init(httpMethod: HttpMethod, url: URL, headers: HttpHeaders, body: Data?) {
        self.httpMethod = httpMethod
        self.url = url
        self.headers = headers
        self.body = body
    }
}
