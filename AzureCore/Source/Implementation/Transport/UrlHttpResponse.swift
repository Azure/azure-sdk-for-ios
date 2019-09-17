//
//  URLHttpResponse.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/5/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class UrlHttpResponse: HttpResponse {
    private var internalResponse: HTTPURLResponse?

    @objc public init(request: HttpRequest, response: HTTPURLResponse?, blockSize: NSNumber = 4096) {
        self.internalResponse = response
        super.init(request: request, blockSize: blockSize)
        if let statusCode = response?.statusCode {
            self.statusCode = NSNumber(value: statusCode)
        }
    }
}
