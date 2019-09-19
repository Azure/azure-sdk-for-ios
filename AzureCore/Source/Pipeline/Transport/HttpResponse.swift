//
//  HttpResponse.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

public class HttpResponse {

    public var httpRequest: HttpRequest?
    public var statusCode: Int?
    public var headers: HttpHeaders?
    public var blockSize: Int?
    public var data: Data?
    public var body: Data? {
        get {
            return self.data
        }
        set(newValue) {
            self.data = newValue
        }
    }

    public init() {}

    public init(request: HttpRequest, blockSize: Int = 4096) {
        self.httpRequest = request
        self.headers = HttpHeaders()
        self.blockSize = blockSize
    }

    public func update(withResponse response: HttpResponse) {
        httpRequest = response.httpRequest
        headers = response.headers
        blockSize = response.blockSize
        statusCode = response.statusCode
        data = response.data
    }

//    public func text(encoding: String = "utf-8") {
//        // TODO: Implement
//        // return self.body.decode(encoding)
//    }

    // TODO: Implmenet
//    public func streamDownload(pipeline: Pipeline) -> ByteIterator {
//
//    }
}
