//
//  PagedCollection.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/19/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation
import os.log

// MARK: - Swift Collection<T>

public struct PagedCodingKeys {
    public let items: String
    public let continuationToken: String
    
    public init(items: String = "items", continuationToken: String = "continuationToken") {
        self.items = items
        self.continuationToken = continuationToken
    }
}

public class PagedCollection<Element: Codable>: PagedIterable {

    public typealias Element = Element

    private var items: [Element]?
    private var continuationToken: String?

    private var iteratorIndex: Int = 0
    private let client: PipelineClient
    private let codingKeys: PagedCodingKeys

    public var underestimatedCount: Int {
        return items?.count ?? 0
    }

    private func update(with data: Data?) throws {
        guard let data = data else { throw HttpResponseError.decode }
        let codingKeys = self.codingKeys
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let itemJson = json[codingKeys.items] {
                let decoder = JSONDecoder()
                let itemData = try JSONSerialization.data(withJSONObject: itemJson)
                self.items = try decoder.decode([Element].self, from: itemData)
            } else {
                self.items = nil
            }
            self.continuationToken = json[codingKeys.continuationToken] as? String
        } else {
            self.items = nil
        }
        self.iteratorIndex = 0
    }

    public init(client: PipelineClient, data: Data?, codingKeys: PagedCodingKeys? = nil) throws {
        guard let data = data else { throw HttpResponseError.decode }
        self.client = client
        self.codingKeys = codingKeys ?? PagedCodingKeys()
        try update(with: data)
    }

    public func nextPage() throws -> [Element]? {
        guard let continuationToken = continuationToken else { return nil }
        os_log("Fetching next page with: %@", continuationToken)
        let request = client.request(method: .GET,
                                     urlTemplate: continuationToken)
        let semaphore = DispatchSemaphore(value: 0)
        client.run(request: request, completion: { result, _ in
            switch result {
            case .failure(let error):
                os_log("Error: %@", error.localizedDescription)
            case .success(let data):
                do {
                    try self.update(with: data)
                } catch {
                    os_log("Error: %@", error.localizedDescription)
                }
            }
            semaphore.signal()
        })
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return self.items
    }

    public func next() -> Element? {
        guard let items = items else { return nil }
        if iteratorIndex >= items.count {
            do {
                _ = try nextPage()
            } catch {
                os_log("Error: %@", error.localizedDescription)
                return nil
            }
        }
        let item = self.items?[iteratorIndex]
        iteratorIndex += 1
        return item
    }
}

//func makeAPICall() -> Result<String?, Error> {
//    let path = "https://jsonplaceholder.typicode.com/todos/1"
//    guard let url = URL(string: path) else { return .failure(.url) }
//    var result: Result<String?, Error>!
//    let semaphore = DispatchSemaphore(value: 0)
//    URLSession.shared.dataTask(with: url) { (data, _, _) in
//        if let data = data {
//            result = .success(String(data: data, encoding: .utf8))
//        } else {
//            result = .failure(.server)
//        }
//        semaphore.signal()
//    }.resume()
//    _ = semaphore.wait(wallTimeout: .distantFuture)
//    return result
//}
//
//func load() {
//    DispatchQueue.global(qos: .utility).async {
//        let result = self.makeAPICall().flatMap { self.anotherAPICall($0) }.flatMap { self.andAnotherAPICall($0) }
//        DispatchQueue.main.async {
//            switch result {
//            case let .success(data):
//                print(data)
//            case let .failure(error):
//                print(error)
//            }
//        }
//    }
//}
