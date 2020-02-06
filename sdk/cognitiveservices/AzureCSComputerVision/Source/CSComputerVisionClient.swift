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
class CSComputerVisionClient: NSObject {
    let credential: CSComputerVisionClientCredentials
    let endpoint: URL?

    @objc init(withEndpoint endpoint: String, withKey key: String, withRegion region: String?) throws {
        credential = try CSComputerVisionClientCredentials(withEndpoint: endpoint, withKey: key, withRegion: region)
        self.endpoint = URL(string: endpoint)
    }

    func extractText(fromResult result: Any?) -> [String] {
        guard result != nil else { return [] }
        var strings = [String]()
        if let resultDict = result as? NSDictionary {
            for (key, value) in resultDict {
                if String(describing: key) == "text" {
                    strings.append(String(describing: value))
                    continue
                }
                strings.append(contentsOf: extractText(fromResult: value))
            }
        }
        if let resultList = result as? NSArray {
            for item in resultList {
                strings.append(contentsOf: extractText(fromResult: item))
            }
        }
        return strings
    }

    @objc func recognizeText(fromUrl url: URL, withLanauage lang: String, shouldDetectOrientation detectOrientation: Bool, completion: @escaping ([String], NSError?) -> Void) {
        guard endpoint != nil else { return }

        let baseUrl = "\(endpoint!)/vision/v2.0/ocr"
        let queryStringParams = [
            "language": lang,
            "detectOrientation": String(describing: detectOrientation)
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
        let jsonBody = try? JSONSerialization.data(withJSONObject: [
            "url": url.absoluteString
        ])
        request.httpBody = jsonBody
        request.allHTTPHeaderFields = headers
        credential.setAuthorizationheaders(forRequest: &request)

        // Now use this URLRequest with Alamofire to make request
//        Alamofire.request(request).responseJSON { response in
//            let result = self.extractText(fromResult: response.result.value)
//            completion(result, nil)
//        }
    }

    @objc func recognizeText(fromImage image: UIImage, withLanguage lang: String, shouldDetectOrientation detectOrientation: Bool, completion: @escaping ([String], NSError?) -> Void) {
        guard endpoint != nil else { return }

        let baseUrl = "\(endpoint!)/vision/v2.0/ocr"
        let queryStringParams = [
            "language": lang,
            "detectOrientation": String(describing: detectOrientation)
        ]
        var urlComponent = URLComponents(string: baseUrl)!
        urlComponent.queryItems = queryStringParams.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        let headers = [
            "Content-Type": "application/octet-stream"
        ]
        var request = URLRequest(url: urlComponent.url!)
        request.httpMethod = "POST"
        request.httpBody = image.pngData()
        request.allHTTPHeaderFields = headers
        credential.setAuthorizationheaders(forRequest: &request)

        // Now use this URLRequest with Alamofire to make request
//        Alamofire.request(request).responseJSON { response in
//            let result = self.extractText(fromResult: response.result.value)
//            completion(result, nil)
//        }
    }
}
