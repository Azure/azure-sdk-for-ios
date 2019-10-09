//
//  HttpResponse.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

public class HttpResponse: HttpMessage {
    public var httpRequest: HttpRequest?
    public var statusCode: Int?
    public var headers = HttpHeaders()
    public var blockSize: Int
    public var data: Data?

    public init(request: HttpRequest, statusCode: Int?, blockSize: Int = 4096) {
        httpRequest = request
        self.blockSize = blockSize
        self.statusCode = statusCode
    }
}
