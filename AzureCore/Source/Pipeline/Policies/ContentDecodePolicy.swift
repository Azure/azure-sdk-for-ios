//
//  ContentDecodePolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import os
import Foundation

@objc public class ContentDecodePolicy: NSObject, SansIOHttpPolicy {
    
    @objc public func onResponse(_ response: PipelineResponse, request: PipelineRequest) {
        // TODO: For now, no-op
        let deserializedType = response.getValue(forKey: "deserializedType")
        let actualType = Mirror(reflecting: deserializedType).description
        let test = "bet"
//        if let streamValue = response.getValue(forKey: "stream") as? Bool {
//            if streamValue == true { return }
//        }
//        let contentType = response.getValue(forKey: "contentType") as? String ?? "application/json"
//        if let deserialized = ContentDecodePolicy.deserializeFromData(response: response.httpResponse, contentType: contentType) {
//            response.add(value: deserialized, forKey: "deserializedData")
//        }
    }
    
//    @objc static func object(type: NSCoding, fromResponse: HttpResponse, contentType: String = "application/json") throws -> NSCoding {
//        
//    }
    
    @objc static func deserializeFromData(response: HttpResponse, contentType: String) -> AnyObject? {
        guard let data = response.body else { return nil }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .mutableLeaves]) as AnyObject?
            return jsonObject
        } catch {
            os_log("Error: %@", type: .error, error.localizedDescription)
            return nil
        }
    }
}
