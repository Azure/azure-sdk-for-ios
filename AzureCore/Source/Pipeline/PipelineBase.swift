//
//  PipelineBase.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/30/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public protocol PipelineSendable {
    @objc var next: PipelineSendable? { get set }
    @objc func send(request: PipelineRequest) throws -> PipelineResponse
}
