//
//  DocumentClientExtensions.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

extension DocumentClient {
    
    fileprivate static let timestamp = "_ts"
    
    
    fileprivate static let roundTripIso8601 = DateFormat.getRoundTripIso8601Formatter()
    
    
    static func roundTripIso8601Encoder(date: Date, encoder: Encoder) throws -> Void {
        
        var container = encoder.singleValueContainer()
        
        if container.codingPath.last?.stringValue == timestamp {
        
            try container.encode(date.timeIntervalSince1970)

        } else {
            
            let data = roundTripIso8601.roundTripIso8601StringWithMicroseconds(from: date)
            
            try container.encode(data)
        }
    }
    
    
    static func roundTripIso8601Decoder(decoder: Decoder) throws -> Date {
        
        let container = try decoder.singleValueContainer()
        
        if container.codingPath.last?.stringValue == timestamp {
            
            let dateDouble = try container.decode(Double.self)
            
            return Date.init(timeIntervalSince1970: dateDouble)
        
        } else {
            
            let dateString = try container.decode(String.self)
            
            guard let microsecondDate = roundTripIso8601.roundTripIso8601DateWithMicroseconds(from: dateString) else {
                throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "unable to parse string (\(dateString)) into date"))
            }
            
            return microsecondDate
        }
    }
}



extension DocumentClient {
    
    /// Creates default values for the "Accept-Encoding", "Accept-Language", "User-Agent", and "x-ms-version" headers.
    static let defaultHttpHeaders: HttpHeaders = {
        
        var headers = Bundle(for: DocumentClient.self).defaultHttpHeaders
        
        // https://docs.microsoft.com/en-us/rest/api/cosmos-db/index#supported-rest-api-versions
        headers[.msVersion] = "2018-12-31"
        
        return headers
    }()
}
