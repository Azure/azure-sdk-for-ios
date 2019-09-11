//
//  Pageable.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/11/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public protocol Pageable {
    var nextLink: String? { get set }
}
