//
//  HttpResponse.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc
public protocol HttpResponse {
    var httpRequest: HttpRequest { get set }
    
    func statusCode() -> Int
    func headerValue(forHeader header: HttpHeader) -> String
    func headers() -> HttpHeaders
    // TODO: Equivalent of Java Flux<ByteBuffer>?
    // func body() -> Data
    func bodyAsByteArray() -> [UInt8]
    func bodyAsString() -> String
    func buffer() -> HttpResponse
}
