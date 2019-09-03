//
//  ContentDecodePolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class ContentDecodePolicy: NSObject, SansIOHttpPolicy {
    
    @objc public func onResponse(_ response: PipelineResponse, request: PipelineRequest) {
        guard response.context?.getValue(forKey: "stream") as? Bool == true else { return }
        let contextName = "deserializedData"
        response.context = response.context?.add(value: ContentDecodePolicy.deserializeFromHttpGenerics(response: response.httpResponse), forKey: contextName)
    }
    
    @objc public static func deserializeFromHttpGenerics(response: HttpResponse) -> AnyObject {
        var contentType = "application/json"
//        if response.contentType {
//            contentType = response.contentType.split(";")[0].strip().lower()
//        }
        return ContentDecodePolicy.deserializeFromText(response: response, contentType: contentType)
    }
    
    @objc public static func deserializeFromText(response: HttpResponse, contentType: String) -> AnyObject {
        // TODO: implement
        return "TBD!" as AnyObject
    }
}
