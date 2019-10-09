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
    public var logger: ClientLogger

    public var context: PipelineContext?

    convenience init(request: HttpRequest, response: HttpResponse, logger: ClientLogger) {
        self.init(request: request, response: response, logger: logger, context: nil)
    }

    init(request: HttpRequest, response: HttpResponse?, logger: ClientLogger, context: PipelineContext?) {
        self.httpRequest = request
        self.httpResponse = response
        self.logger = logger
        self.context = context
    }
}
