//
//  UserAgentPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class UserAgentPolicy: SansIOHttpPolicy {
    
    private var _userAgent: String
    @objc public let userAgentOverwrite: Bool
    @objc public var userAgent: String {
        return self._userAgent
    }

    @objc public init(baseUserAgent: String?, userAgentOverwrite: Bool = false) {
        self.userAgentOverwrite = userAgentOverwrite
        if baseUserAgent == nil {
            // TODO: Update this
            // TODO: Distinguish between Swift and ObjC?
            let swiftVersion = 5.0
            let platform = "iPhone"
            let azureCoreVersion = "0.1.0"
            self._userAgent = "ios/\(swiftVersion) (\(platform)) AzureCore/\(azureCoreVersion)"
        } else {
            self._userAgent = baseUserAgent!
        }
    }
    
    @objc public func appendUserAgent(value: String) {
        self._userAgent = "\(self._userAgent) \(value)"
    }
    
    @objc override func onRequest(_ request: PipelineRequest) {
        let userAgentHeader = HttpHeaderType.userAgent.name()
        if let contextUserAgent = request.context?.getValue(forKey: "userAgent") as? String {
            if request.context?.getValue(forKey: "userAgentOverwrite") != nil {
                request.httpRequest.headers[userAgentHeader] = contextUserAgent
            } else {
                request.httpRequest.headers[userAgentHeader] = "\(self.userAgent) \(contextUserAgent)"
            }
        } else if (self.userAgentOverwrite || request.httpRequest.headers[userAgentHeader] == nil) {
            request.httpRequest.headers[userAgentHeader] = self.userAgent
        }
    }
}
