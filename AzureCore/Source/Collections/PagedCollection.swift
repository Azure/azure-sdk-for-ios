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

public struct PagedCollection<Element: Codable>: PagedIterable, Codable {

    public typealias Element = Element
    
    private var pageItems: [Element]?
    private var nextLink: String?

    private enum CodingKeys: String, CodingKey {
        case pageItems = "items"
        case nextLink = "@nextLink"
    }

    private var iteratorIndex: Int = 0
    private var request: PipelineRequest?
    private var client: PipelineClient?

    public var underestimatedCount: Int {
        return pageItems?.count ?? 0
    }

    mutating public func nextPage() throws -> [Element]? {
        if let nextLink = nextLink {
//            request.httpRequest.format(queryParams: nextLink.parseQueryString())
//
//            client.pipeline.run(request: request, completion: { response, error in
//                // TODO: Re-solve for Async...
//                let test = "best"
//                if let data = response.httpResponse.data {
//                    let decoder = JSONDecoder()
//                    let nextPage = try decoder.decode(PagedCollection<T>.self, from: data)
//                    self.nextLink = nextPage.nextLink
//                    return nextPage.pageItems
//                }
//            })
        }
        return nil
    }

    mutating public func next() -> Element? {
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
