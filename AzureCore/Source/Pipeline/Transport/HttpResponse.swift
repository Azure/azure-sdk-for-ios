//
//  HttpResponse.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

//@objc public protocol HttpResponseProtocol {
//    @objc var data: Data? { get set }
//    @objc var body: Data? { get set }
//}

@objc public class HttpResponse: NSObject {//}, HttpResponseProtocol {
    
    @objc public var httpRequest: HttpRequest?
    @objc public var statusCode: NSNumber?
    @objc public var headers: HttpHeaders?
    @objc public var blockSize: NSNumber?
    @objc public var data: Data?
    @objc public var body: Data? {
        get {
            return self.data
        }
        set(newValue) {
            self.data = newValue
        }
    }

    @objc override public init() {
        super.init()
    }
    
    @objc public init(request: HttpRequest, blockSize: NSNumber = 4096) {
        self.httpRequest = request
        self.headers = HttpHeaders()
        self.blockSize = blockSize
        super.init()
    }

    @objc public func update(withResponse response: HttpResponse) {
        self.httpRequest = response.httpRequest
        self.headers = response.headers
        self.blockSize = response.blockSize
        self.statusCode = response.statusCode
        self.data = response.data
    }
    
//    @objc public func text(encoding: String = "utf-8") {
//        // TODO: Implement
//        // return self.body.decode(encoding)
//    }

    // TODO: Implmenet
//    @objc public func streamDownload(pipeline: Pipeline) -> ByteIterator {
//
//    }
}
