//
//  PagedCollection.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/19/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation
import os.log

// MARK: Paged Collection

/// Defines the property keys used to conform to the Azure paging design.
public struct PagedCodingKeys {
    public let items: String
    public let continuationToken: String

    public init(items: String = "items", continuationToken: String = "continuationToken") {
        self.items = items
        self.continuationToken = continuationToken
    }

    internal func items(fromJson json: [String: Any]) -> [Any]? {
        var results: [Any]?
        let components = items.components(separatedBy: ".")
        var current = json
        for component in components {
            guard let temp = current[component] else { return nil }
            if let tempArray = temp as? [Any] {
                guard results == nil else { return nil }
                results = tempArray
            } else if let tempJson = temp as? [String: Any] {
                current = tempJson
            }
        }
        return results
    }

    internal func continuationToken(fromJson json: [String: Any]) -> String? {
        var result: String?
        let components = continuationToken.components(separatedBy: ".")
        var current = json
        for component in components {
            guard let temp = current[component] else { return nil }
            if let tempString = temp as? String {
                guard result == nil else { return nil }
                result = tempString
            } else if let tempJson = temp as? [String: Any] {
                current = tempJson
            }
        }
        return result
    }
}

/// A collection that fetches paged results in a lazy fashion.
public class PagedCollection<SingleElement: Codable>: Sequence, IteratorProtocol {

    public typealias Element = [SingleElement]

    private var _items: Element?

    /// Returns the current running list of items.
    public var items: Element? {
        return _items
    }

    private var pageRange: Range<Int>?

    /// Returns the subset of items that corresponds to the current page.
    public var pageItems: Element? {
        guard let range = pageRange else { return nil }
        guard let slice = _items?[range] else { return nil }
        return Array(slice)
    }

    /// The continuation token used to fetch the next page of results.
    private var continuationToken: String?

    /// The headers that accompanied the orignal request. Used as the basis for subsequent paged requests.
    private var requestHeaders: HttpHeaders!

    /// An index which tracks the next item to be returned when using the nextItem method.
    private var iteratorIndex: Int = 0

    /// A reference to the configured client that created the PagedCollection. Needed to make follow-up
    /// calls to retrieve additional pages.
    private let client: PipelineClient

    /// The JSON decoder used to deserialze the JSON payload into the appropriate models.
    private let decoder: JSONDecoder

    /// Key values needed to deserialize the service response into items and a continuation token.
    private let codingKeys: PagedCodingKeys

    public var underestimatedCount: Int {
        return items?.count ?? 0
    }

    /// Deserializes the JSON payload to append the new items, update tracking of the "current page" of items
    /// and reset the per page iterator.
    private func update(with data: Data?) throws {
        let noDataError = HttpResponseError.decode("Response data expected but not found.")
        guard let data = data else { throw noDataError }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw noDataError }
        let codingKeys = self.codingKeys
        let notPagedError = HttpResponseError.decode("Paged response expected but not found.")
        guard let itemJson = codingKeys.items(fromJson: json) else { throw notPagedError }
        self.continuationToken = codingKeys.continuationToken(fromJson: json)

        let itemData = try JSONSerialization.data(withJSONObject: itemJson)
        let newItems = try decoder.decode(Element.self, from: itemData)
        if let currentItems = self._items {
            // append rather than throw away old items
            self.pageRange = currentItems.count..<(currentItems.count + newItems.count)
            self._items = currentItems + newItems
        } else {
            self._items = newItems
            self.pageRange = 0..<newItems.count
        }
    }

    public init(client: PipelineClient, request: HttpRequest, data: Data?, codingKeys: PagedCodingKeys? = nil,
                decoder: JSONDecoder? = nil) throws {
        let noDataError = HttpResponseError.decode("Response data expected but not found.")
        guard let data = data else { throw noDataError }
        self.client = client
        self.decoder = decoder ?? JSONDecoder()
        self.codingKeys = codingKeys ?? PagedCodingKeys()
        self.requestHeaders = request.headers
        try update(with: data)
    }

    /// Retrieves the next page of results asynchronously.
    public func nextPage(then completion: @escaping (Result<Element?, Error>) -> Void) {
        guard let continuationToken = continuationToken else {
            completion(.success(nil))
            return
        }
        client.logger.info(String(format: "Fetching next page with: %@", continuationToken))
        let queryParams = [String: String]()
        let url = client.format(urlTemplate: continuationToken)
        let request = client.request(method: .GET,
                                     url: url,
                                     queryParams: queryParams,
                                     headerParams: requestHeaders)
        client.run(request: request, allowedStatusCodes: [200]) { result, _ in
            var returnError: Error?
            switch result {
            case .failure(let error):
                returnError = error
            case .success(let data):
                do {
                    try self.update(with: data)
                } catch {
                    returnError = error
                }
            }
            if let returnError = returnError {
                completion(.failure(returnError))
            }
            self.iteratorIndex = 0
            completion(.success(self.pageItems))
        }
    }

    /// Retrieves the next item in the collection, automatically fetching new pages when needed.
    public func nextItem(then completion: @escaping (Result<SingleElement?, Error>) -> Void) {
        guard let pageItems = pageItems else {
            completion(.success(nil))
            return
        }
        if iteratorIndex >= pageItems.count {
            nextPage { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let newPage):
                    if let newPage = newPage {
                        // since we return the first new item, the next iteration should start with the second item.
                        self.iteratorIndex = 1
                        completion(.success(newPage[0]))
                    } else {
                        self.iteratorIndex = 0
                        completion(.success(nil))
                    }
                }
            }
        } else {
            if let item = self.pageItems?[iteratorIndex] {
                iteratorIndex += 1
                completion(.success(item))
            } else {
                iteratorIndex = 0
                completion(.success(nil))
            }
        }
    }

    // MARK: Iterator Protocol

    /// Returns the next page of results. In order to conform with the protocol, this
    /// usage must be synchronous.
    public func next() -> Element? {
        guard let items = items else { return nil }
        if iteratorIndex < items.count {
            iteratorIndex = items.count
            return items
        }
        // must force synchronous behavior due to the constraints
        // of the protocol.
        let semaphore = DispatchSemaphore(value: 0)
        var newItems: Element?
        let logger = client.logger
        nextPage { result in
            switch result {
            case .success(let newPage):
                self.iteratorIndex = newPage?.count ?? 0
                newItems = newPage
            case .failure(let error):
                logger.error(String(format: "Error: %@", error.localizedDescription))
                newItems = nil
            }
            semaphore.signal()
        }
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return newItems
    }
}
