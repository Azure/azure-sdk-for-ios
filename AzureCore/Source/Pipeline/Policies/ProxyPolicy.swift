//
//  ProxyPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class ProxyPolicy: NSObject, SansIOHttpPolicy {
    
    @objc public var proxies: [String:String]?
    
    @objc public init(proxies: [String:String]? = nil) {
        self.proxies = proxies
    }
    
    @objc public func onRequest(_ request: PipelineRequest) {
        guard let proxies = self.proxies else { return }
        request.context = request.context?.add(value: proxies as AnyObject, forKey: "proxies")
    }
}
