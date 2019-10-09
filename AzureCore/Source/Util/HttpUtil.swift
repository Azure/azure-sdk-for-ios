//
//  HttpUtil.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/19/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

extension String {
    /// Parses a query string into a dictionary of key-value pairs.
    public func parseQueryString() -> [String: String]? {
        guard let urlComps = URLComponents(string: self) else { return nil }
        guard let queryString = urlComps.query else { return nil }
        var queryItems = [String: String]()

        for component in queryString.components(separatedBy: "&") {
            if component == "" { continue }
            let splitComponent = component.split(separator: "=", maxSplits: 1).map(String.init)
            let name = splitComponent.first!
            let value = splitComponent.count == 2 ? splitComponent.last : ""
            queryItems[name] = value
        }
        return queryItems
    }
}

extension Dictionary where Key == String, Value == String {
    public func convertToQueryItems() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        for (key, value) in self {
            queryItems.append(
                URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                // URLQueryItem(name: key, value: value)
            )
        }
        return queryItems
    }
}
