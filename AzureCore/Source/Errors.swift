//
//  AzureErrors.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/14/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

public enum AzureError: Error {
    case general
    case serviceRequest
    case serviceResponse
}

public enum HttpResponseError: Error {
    case general
    case decode
    case resourceExists
    case resourceNotFound
    case clientAuthentication
    case resourceModified
    case tooManyRedirects
}
