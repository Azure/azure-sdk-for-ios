//
//  CSComputerVisionClient.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/12/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import AzureCore
import Foundation

@objc
class CSComputerVisionClient: NSObject {
    let credential: CSComputerVisionClientCredentials
    let endpoint: URL?
    
    @objc init(withEndpoint endpoint: String, withKey key: String, withRegion region: String?) throws {
        self.credential = try CSComputerVisionClientCredentials.init(withEndpoint: endpoint, withKey: key, withRegion: region)
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

        guard self.endpoint != nil else { return }
        
        let baseUrl = "\(self.endpoint!)/vision/v2.0/ocr"
        let queryStringParams = [
            "language": lang,
            "detectOrientation": detectOrientation.description
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
        self.credential.setAuthorizationheaders(forRequest: &request)
        
        //Now use this URLRequest with Alamofire to make request
        Alamofire.request(request).responseJSON { response in
            let result = self.extractText(fromResult: response.result.value)
            completion(result, nil)
        }
    }
    
    @objc func recognizeText(fromImage image: UIImage, withLanguage lang: String, shouldDetectOrientation detectOrientation: Bool, completion: @escaping ([String], NSError?) -> Void) {
        guard self.endpoint != nil else { return }

        let baseUrl = "\(self.endpoint!)/vision/v2.0/ocr"
        let queryStringParams = [
            "language": lang,
            "detectOrientation": detectOrientation.description
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
        self.credential.setAuthorizationheaders(forRequest: &request)
        
        //Now use this URLRequest with Alamofire to make request
        Alamofire.request(request).responseJSON { response in
            let result = self.extractText(fromResult: response.result.value)
            completion(result, nil)
        }
    }
}
