//
//  PipelineError.swift
//  AzureCore
//
//  Created by Brandon Siegel on 10/7/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public final class PipelineError: Error {
    public var innerError: Error
    public var pipelineResponse: PipelineResponse

    init(fromError innerError: Error, pipelineResponse: PipelineResponse) {
        self.innerError = innerError
        self.pipelineResponse = pipelineResponse
    }
}
