//
//  Iterable.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/17/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

protocol Iterable: ObjectiveCBridgeable, Sequence {
    func byItem()
    func nextItem()
}

protocol StreamIterable: Iterable {}

protocol PagedIterable: Iterable {
    func byPage()
    func nextPage()
}
