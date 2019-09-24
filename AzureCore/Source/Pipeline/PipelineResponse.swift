//
//  PipelineResponse.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

final public class PipelineResponse: PipelineContextProtocol {

    public var httpRequest: HttpRequest
    public var httpResponse: HttpResponse?

    public var context: PipelineContext?

    convenience init(request: HttpRequest, response: HttpResponse) {
        self.init(request: request, response: response, context: nil)
    }

    init(request: HttpRequest, response: HttpResponse?, context: PipelineContext?) {
        self.httpRequest = request
        self.httpResponse = response
        self.context = context
    }
}
