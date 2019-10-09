//
//  HttpMessage.swift
//  AzureCore
//
//  Created by Brandon Siegel on 10/7/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public protocol HttpMessage {
    var headers: HttpHeaders { get set }
    var data: Data? { get set }
}

public extension HttpMessage {
    func text(encoding: String.Encoding = .utf8) -> String? {
        guard let data = self.data else { return nil }
        return String(data: data, encoding: encoding)
    }
}
