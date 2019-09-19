//
//  URLHttpResponse.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/5/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class UrlHttpResponse: HttpResponse {
    private var internalResponse: HTTPURLResponse?

    public init(request: HttpRequest, response: HTTPURLResponse?, blockSize: Int = 4096) {
        self.internalResponse = response
        super.init(request: request, blockSize: blockSize)
        if let statusCode = response?.statusCode {
            self.statusCode = statusCode
        }
    }
}
