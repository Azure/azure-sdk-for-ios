//
//  CustomDocument.swift
//  AzureData iOS Example
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureData


//typealias documentType = DictionaryDocument
typealias documentType = CustomDocument


class CustomDocument: Document {
    
    var testDate:   Date?
    var testNumber: Double?
    var testString: String?
    
    public override init () { super.init() }
    public override init (_ id: String) { super.init(id) }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        testDate    = try container.decode(Date?.self,   forKey: .testDate)
        testNumber  = try container.decode(Double?.self, forKey: .testNumber)
        testString  = try container.decode(String?.self, forKey: .testString)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(testDate,      forKey: .testDate)
        try container.encode(testNumber,    forKey: .testNumber)
        try container.encode(testString,    forKey: .testString)
    }
    
    private enum CodingKeys: String, CodingKey {
        case testDate
        case testNumber
        case testString
    }
    
    override var debugDescription: String {
        return "\(super.debugDescription)\n\ttestNumber : \(testNumber ?? 0)\n\ttestDate : \(testDate?.debugDescription ?? "nil")\n\ttestString : \(testString ?? "nil")\n--"
    }
}
