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

public struct PagedCollection<T: Codable>: PagedIterable, Codable {

    public typealias Element = T

    private var pageItems: [T]?
    private var nextLink: String?

    private enum CodingKeys: String, CodingKey {
        case pageItems = "items"
        case nextLink = "@nextLink"
    }

    // swiftlint:disable redundant_optional_initialization
    private var iteratorIndex: Int = 0
    public var request: PipelineRequest? = nil
    public var client: PipelineClient? = nil
    // swiftlint:enable redundant_optional_initialization

    public var underestimatedCount: Int {
        return pageItems?.count ?? 0
    }

    mutating public func nextPage() throws -> [T]? {
        print("NextPage called with NextLink: \(nextLink ?? "nil")")
        guard client != nil && request != nil else {
            throw HttpResponseError.general
        }
        if let nextLink = nextLink {
            // TODO: Re-solve for Async... 
//            request!.httpRequest.format(queryParams: nextLink.parseQueryString())
//            let nextResponse = try client!.pipeline.run(request: request!)
//            if let data = nextResponse.httpResponse.data {
//                let decoder = JSONDecoder()
//                let nextPage = try decoder.decode(PagedCollection<T>.self, from: data)
//                self.nextLink = nextPage.nextLink
//                return nextPage.pageItems
//            }
        }
        return nil
    }

    mutating public func next() -> T? {
        guard let pageItems = pageItems else { return nil }
        if iteratorIndex >= pageItems.count {
            do {
                self.pageItems = try nextPage()
                self.iteratorIndex = 0
            } catch {
                os_log("Error: %@", error.localizedDescription)
                return nil
            }
        }
        let item = pageItems[iteratorIndex]
        iteratorIndex += 1
        return item
    }
}
