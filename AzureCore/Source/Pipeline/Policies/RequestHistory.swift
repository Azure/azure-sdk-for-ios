//
//  RequestHistory.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/24/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class RequestHistory {
    let httpRequest: HttpRequest
    let httpResponse: HttpResponse
    let error: Error?
    let context: PipelineContext?

    public init(request: HttpRequest, response: HttpResponse, context: PipelineContext?, error: Error?) {
        // TODO: request should be a deep copy
        self.httpRequest = request
        self.httpResponse = response
        self.error = error
        self.context = context
    }
}
