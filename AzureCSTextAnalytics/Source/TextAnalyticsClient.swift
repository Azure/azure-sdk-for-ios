//
//  CSTextAnalyticsClient.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/13/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation
import AzureCore

@objc
class TextAnalyticsClient: NSObject {
    let credential: TextAnalyticsClientCredentials
    let endpoint: URL?
    
    @objc init(withEndpoint endpoint: String, withKey key: String, withRegion region: String?) throws {
        self.credential = try TextAnalyticsClientCredentials.init(withEndpoint: endpoint, withKey: key, withRegion: region)
        self.endpoint = URL(string: endpoint)
    }
    
    @objc func getSentiment(fromText text: String, withLanauage lang: String?, showStats: Bool = false, completion: @escaping (Float, NSError?) -> Void) {

        guard self.endpoint != nil else { return }
        
        let baseUrl = "\(self.endpoint!)/text/analytics/v2.1/sentiment"
        let queryStringParams = [
            "showStats": String(showStats)
        ]
        var urlComponent = URLComponents(string: baseUrl)!
        urlComponent.queryItems = queryStringParams.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        let headers = [
            "Content-Type": "application/json"
        ]
        var request = URLRequest(url: urlComponent.url!)
        request.httpMethod = "POST"
        let jsonDict = [
            "documents": [
                [
                    "language": "en",
                    "id": "1",
                    "text": text
                ]
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonDict)
        request.allHTTPHeaderFields = headers
        self.credential.setAuthorizationheaders(forRequest: &request)

        //Now use this URLRequest with Alamofire to make request
//        Alamofire.request(request).responseJSON { response in
//            guard let json = (response.result.value as? NSDictionary) else { return }
//            guard let docs = (json["documents"] as? NSArray) else { return }
//            guard let doc = (docs[0] as? NSDictionary) else { return }
//            guard let score = (doc["score"] as? NSNumber) else { return }
//            completion(Float(truncating: score), nil)
//        }
    }
}
