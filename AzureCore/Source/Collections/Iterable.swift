//
//  Iterable.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/17/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

protocol Iterable: Sequence, IteratorProtocol {}

protocol PagedIterable: Iterable {

    associatedtype Element

    mutating func nextPage() throws -> [Element]?
}
