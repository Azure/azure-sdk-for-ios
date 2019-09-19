//
//  CustomHookPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class CustomHookPolicy: SansIOHttpPolicy {

    private var callback: ((PipelineResponse) -> Void)?

    public func onRequest(_ request: PipelineRequest) {
        self.callback = request.context?.getValue(forKey: "rawResponseHook") as? ((PipelineResponse) -> Void)
    }

    public func onResponse(_ response: PipelineResponse, request: PipelineRequest) {
        guard let callback = self.callback else { return }
        callback(response)
        request.context = request.context?.add(value: self.callback as AnyObject, forKey: "rawResponseHook")
    }

    public init(withCallback callback: ((PipelineResponse) -> Void)? = nil) {
        self.callback = callback
    }
}
