//
//  PipelineRequest.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

final public class PipelineRequest: PipelineContextProtocol {

    public var httpRequest: HttpRequest

    public var context: PipelineContext?

    public convenience init(request: HttpRequest) {
        self.init(request: request, context: nil)
    }

    public init(request: HttpRequest, context: PipelineContext?) {
        self.httpRequest = request
        self.context = context
    }
}
