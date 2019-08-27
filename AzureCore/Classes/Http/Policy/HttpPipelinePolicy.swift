//
//  HttpPipelinePolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc protocol HttpPipelinePolicy {
    @objc func process(context: HttpPipelineCallContext, next: HttpPipelineNextPolicy) -> HttpResponse
}
