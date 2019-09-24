//
//  PipelineBase.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/30/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public protocol PipelineSendable {
    var next: PipelineSendable? { get set }
    func send(request: PipelineRequest, onResult: @escaping CompletionHandler) throws
}
