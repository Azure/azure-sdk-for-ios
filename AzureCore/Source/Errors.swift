//
//  AzureErrors.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/14/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

public enum AzureError: Error {
    case general(String)
    case serviceRequest(String)
    case serviceResponse(String)
}

public enum HttpResponseError: Error {
    case general(String)
    case decode(String)
    case resourceExists(String)
    case resourceNotFound(String)
    case clientAuthentication(String)
    case resourceModified(String)
    case tooManyRedirects(String)
    case statusCode(String)
}
