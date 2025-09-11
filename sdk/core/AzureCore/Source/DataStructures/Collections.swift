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

import Foundation
#if canImport(os)
import os.log
#endif

public typealias Continuation<T> = (Result<T, AzureError>) -> Void

/// Protocol which allows clients to customize how they work with Paged Collections.
public protocol PageableClient: PipelineClient {
    // MARK: Required Methods

    func continuationUrl(forRequestUrl requestUrl: URL, withContinuationToken token: String) -> URL?
}

/// Defines the property keys used to conform to the Azure paging design.
public struct PagedCodingKeys {
    // MARK: Properties

    public let items: String
    public let xmlItemName: String?
    public let continuationToken: String

    // MARK: Initializers

    public init(
        items: String = "items",
        continuationToken: String = "continuationToken",
        xmlItemName xmlName: String? = nil
    ) {
        self.items = items
        self.continuationToken = continuationToken
        self.xmlItemName = xmlName
    }

    // MARK: Internal Methods

    func items(fromJson json: [String: Any]) -> [Any]? {
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

    func continuationToken(fromJson json: [String: Any]) -> String? {
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
public class PagedCollection<SingleElement: Codable> {
    // MARK: Properties

    public typealias Element = [SingleElement]

    /// Returns the current running list of items.
    public var items: Element? {
        return _items
    }

    /// Returns the subset of items that corresponds to the current page.
    public var pageItems: Element? {
        guard let range = pageRange else { return nil }
        guard let slice = _items?[range] else { return nil }
        return Array(slice)
    }

    /// Returns the count of items that have been retrieved so far. There may
    /// be additional results, not yet fetched.
    public var underestimatedCount: Int {
        return items?.count ?? 0
    }

    /// Returns true if there are no more results to fetch.
    public var isExhausted: Bool {
        return continuationToken == nil || continuationToken == ""
    }

    // Synchronous iterator for retrieving paged items.
    public struct PagedItemSyncIterator: Sequence, IteratorProtocol {
        let pagedCollection: PagedCollection

        public mutating func next() -> SingleElement? {
            guard !Thread.isMainThread else {
                return nil
            }
            var item: SingleElement?
            let semaphore = DispatchSemaphore(value: 0)
            pagedCollection.nextItem { result in
                switch result {
                case let .success(retrievedItem):
                    item = retrievedItem
                default:
                    item = nil
                }
                semaphore.signal()
            }
            semaphore.wait()
            return item
        }

        public init(_ pagedCollection: PagedCollection) {
            self.pagedCollection = pagedCollection
        }
    }

    /// Returns a iterator to retrieve paged items one at a time.
    public var syncIterator: PagedItemSyncIterator {
        return PagedItemSyncIterator(self)
    }

    private var _items: Element?

    private var pageRange: Range<Int>?

    /// The continuation token used to fetch the next page of results.
    var continuationToken: String?

    /// The headers that accompanied the orignal request. Used as the basis for subsequent paged requests.
    private var requestHeaders: HTTPHeaders!

    /// An index which tracks the next item to be returned when using the nextItem method.
    private var iteratorIndex: Int = 0

    /// A reference to the configured client that created the PagedCollection. Needed to make follow-up
    /// calls to retrieve additional pages.
    private let client: PageableClient

    /// The `PipelineContext` that will be reused for subsequent paging calls.
    private let context: PipelineContext

    /// The JSON decoder used to deserialze the JSON payload into the appropriate models.
    private let decoder: JSONDecoder

    /// Key values needed to deserialize the service response into items and a continuation token.
    private let codingKeys: PagedCodingKeys

    /// The initial request URL
    private var requestUrl: URL

    // MARK: Initializers

    /// <#Description#>
    /// - Parameters:
    ///   - client: The `PageableClient` used to make calls for follow-up pages.
    ///   - request: The original `HTTPRequest` used to make the call.
    ///   - context: A `PipelineContext` object that will be used for follow-up page requests.
    ///   - data: The `Data` corresponding to the first page results.
    ///   - codingKeys: An optional set of `PagedCodingKeys` used to decode the paged results.
    ///   - decoder: An optional `JSONDecoder` for decoding special types.
    /// - Throws: `AzureErrors.sdk` thrown if no data is returned from the server.
    public init(
        client: PageableClient,
        request: HTTPRequest,
        context: PipelineContext,
        data: Data?,
        codingKeys: PagedCodingKeys? = nil,
        decoder: JSONDecoder? = nil
    ) throws {
        let noDataError = AzureError.client("Response data expected but not found.")
        guard let data = data else { throw noDataError }
        self.client = client
        self.context = context
        self.decoder = decoder ?? JSONDecoder()
        self.codingKeys = codingKeys ?? PagedCodingKeys()
        self.requestHeaders = request.headers
        self.requestUrl = request.url
        try update(with: data)
    }

    // MARK: Public Methods

    /// Retrieves the next page of results asynchronously.
    public func nextPage(completionHandler: @escaping Continuation<Element>) {
        // exit if there is no valid continuation token
        guard let continuationToken = continuationToken, !self.isExhausted else {
            let error = AzureError.client("Paged collection exhausted.")
            completionHandler(.failure(error))
            return
        }

        client.logger.info(String(format: "Fetching next page with: %@", continuationToken))
        guard let url = client.continuationUrl(forRequestUrl: requestUrl, withContinuationToken: continuationToken)
        else { return }

        // Reset the cancellation token for the new page request
        let cancellationToken = context.value(forKey: .cancellationToken) as? CancellationToken
        cancellationToken?.reset()
        context.add(cancellationToken: cancellationToken, applying: client.commonOptions)

        guard let request = try? HTTPRequest(method: .get, url: url, headers: requestHeaders) else { return }
        client.request(request, context: context) { result, _ in
            var returnError: AzureError?
            switch result {
            case let .failure(error):
                returnError = error
            case let .success(data):
                do {
                    try self.update(with: data)
                } catch {
                    returnError = AzureError.client("Error updating page.", error)
                }
            }
            if let returnError = returnError {
                completionHandler(.failure(returnError))
                return
            }
            self.iteratorIndex = 0
            if let pageItems = self.pageItems {
                completionHandler(.success(pageItems))
            }
        }
    }

    @available(iOS 13.0.0, *)
    /// Retrieves the next page of results asynchronously.
    public func nextPage() async throws -> [SingleElement] {
        try await withCheckedThrowingContinuation { continuation in
            nextPage { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Retrieves the next item in the collection, automatically fetching new pages when needed.
    public func nextItem(completionHandler: @escaping Continuation<SingleElement>) {
        guard let pageItems = pageItems else {
            // do not call the completion handler if there is no data
            return
        }
        if iteratorIndex >= pageItems.count {
            nextPage { result in
                switch result {
                case let .failure(error):
                    completionHandler(.failure(error))
                case let .success(newPage):
                    // since we return the first new item, the next iteration should start with the second item.
                    self.iteratorIndex = 1
                    completionHandler(.success(newPage[0]))
                }
            }
        } else {
            if let item = self.pageItems?[iteratorIndex] {
                iteratorIndex += 1
                completionHandler(.success(item))
            }
        }
    }

    @available(iOS 13.0.0, *)
    public func nextItem() async throws -> SingleElement {
        return try await withCheckedThrowingContinuation { continuation in
            nextItem { result in
                continuation.resume(with: result)
            }
        }
    }

    public func forEachPage(progressHandler: @escaping (Element) -> Bool) {
        let dispatchQueue = client.commonOptions.dispatchQueue ?? DispatchQueue(label: "ForEachPage", qos: .utility)
        let semaphore = DispatchSemaphore(value: 1)
        let group = DispatchGroup()
        dispatchQueue.async(group: group) { [weak self] in
            while !(self?.isExhausted ?? true) {
                group.enter()
                semaphore.wait()
                self?.nextPage { result in
                    group.leave()
                    semaphore.signal()
                    switch result {
                    case let .success(paged):
                        guard progressHandler(paged) else { return }
                    case .failure:
                        return
                    }
                }
            }
        }
    }

    public func forEachItem(progressHandler: @escaping (SingleElement) -> Bool) {
        let dispatchQueue = client.commonOptions.dispatchQueue ?? DispatchQueue(label: "ForEachItem", qos: .utility)
        let semaphore = DispatchSemaphore(value: 1)
        let group = DispatchGroup()
        dispatchQueue.async(group: group) { [weak self] in
            while !(self?.isExhausted ?? true) {
                group.enter()
                semaphore.wait()
                self?.nextItem { result in
                    group.leave()
                    semaphore.signal()
                    switch result {
                    case let .success(item):
                        guard progressHandler(item) else { return }
                    case .failure:
                        return
                    }
                }
            }
        }
    }

    // MARK: Private Methods

    /// Deserializes the JSON payload to append the new items, update tracking of the "current page" of items
    /// and reset the per page iterator.
    private func update(with data: Data?) throws {
        let noDataError = AzureError.client("Response data expected but not found.")
        guard let data = data else { throw noDataError }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw noDataError }
        let codingKeys = self.codingKeys
        let notPagedError = AzureError.client("Paged response expected but not found.")
        guard let itemJson = codingKeys.items(fromJson: json) else { throw notPagedError }
        continuationToken = codingKeys.continuationToken(fromJson: json)

        let itemData = try JSONSerialization.data(withJSONObject: itemJson)
        let newItems = try decoder.decode(Element.self, from: itemData)
        if let currentItems = _items {
            // append rather than throw away old items
            pageRange = currentItems.count ..< (currentItems.count + newItems.count)
            _items = currentItems + newItems
        } else {
            _items = newItems
            pageRange = 0 ..< newItems.count
        }
    }
}
