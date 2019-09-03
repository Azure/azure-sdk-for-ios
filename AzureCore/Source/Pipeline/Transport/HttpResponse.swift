//
//  HttpResponse.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc public class HttpResponse: NSObject {
    
    @objc public var httpRequest: HttpRequest
    @objc public let statusCode: Int = 500
    @objc public let headers: HttpHeaders
    @objc public let reason: String?
    @objc public let contentType: String?
    @objc public let blockSize: Int

    private let internalResponse: AnyObject?

    @objc public init(request: HttpRequest, internalResponse: AnyObject?, blockSize: Int = 4096) {
        self.httpRequest = request
        self.internalResponse = internalResponse
        self.headers = HttpHeaders()
        self.reason = nil
        self.contentType = nil
        self.blockSize = blockSize
    }
    
    @objc public func body() -> Data? {
        // TODO: implement properly
        return Data(base64Encoded: "Foo")
    }
    
    @objc public func text(encoding: String = "utf-8") {
        // TODO: Implement
        // return self.body.decode(encoding)
    }

    // TODO: Implmenet
//    @objc public func streamDownload(pipeline: Pipeline) -> ByteIterator {
//
//    }
}
