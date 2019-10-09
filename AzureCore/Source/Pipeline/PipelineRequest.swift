//
//  PipelineRequest.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public final class PipelineRequest: PipelineContextProtocol {
    public var httpRequest: HttpRequest
    public var logger: ClientLogger

    public var context: PipelineContext?

    public convenience init(request: HttpRequest, logger: ClientLogger) {
        self.init(request: request, logger: logger, context: nil)
    }

    public init(request: HttpRequest, logger: ClientLogger, context: PipelineContext?) {
        httpRequest = request
        self.logger = logger
        self.context = context
    }
}
