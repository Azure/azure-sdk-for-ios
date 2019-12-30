// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCore
import Foundation

@objc
class TextAnalyticsClient: NSObject {
    let credential: TextAnalyticsClientCredentials
    let endpoint: URL?

    @objc init(withEndpoint endpoint: String, withKey key: String, withRegion region: String?) throws {
        credential = try TextAnalyticsClientCredentials(withEndpoint: endpoint, withKey: key, withRegion: region)
        self.endpoint = URL(string: endpoint)
    }

    @objc func getSentiment(fromText text: String, withLanauage _: String?, showStats: Bool = false, completion _: @escaping (Float, NSError?) -> Void) {
        guard endpoint != nil else { return }

        let baseUrl = "\(endpoint!)/text/analytics/v2.1/sentiment"
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
        credential.setAuthorizationheaders(forRequest: &request)

        // Now use this URLRequest with Alamofire to make request
//        Alamofire.request(request).responseJSON { response in
//            guard let json = (response.result.value as? NSDictionary) else { return }
//            guard let docs = (json["documents"] as? NSArray) else { return }
//            guard let doc = (docs[0] as? NSDictionary) else { return }
//            guard let score = (doc["score"] as? NSNumber) else { return }
//            completion(Float(truncating: score), nil)
//        }
    }
}
