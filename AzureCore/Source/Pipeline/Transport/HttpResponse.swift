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
    public var blockSize: Int
    public var data: Data?
    public var body: Data? {
        get {
            return self.data
        }
        set(newValue) {
            self.data = newValue
        }
    }

    public init(request: HttpRequest, statusCode: Int?, blockSize: Int = 4096) {
        self.httpRequest = request
        self.headers = HttpHeaders()
        self.blockSize = blockSize
        self.statusCode = statusCode
    }
}
