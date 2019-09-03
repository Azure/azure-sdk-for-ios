//
//  PipelineClient.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class PipelineClient: NSObject {
    // TODO: include PipelineBase
    @objc let baseUrl: URL
    @objc let config: PipelineConfiguration
    
    @objc public init(baseUrl: URL, config: PipelineConfiguration) {
        self.baseUrl = baseUrl
        self.config = config
    }
}
