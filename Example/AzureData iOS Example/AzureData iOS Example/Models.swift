//
//  Models.swift
//  AzureDataApp
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureData

class Person: Document {
    
    var firstName:  String?
    var lastName:   String?
    var age:        Int?
    var email:      String?

    public override init () { super.init() }
    public override init (_ id: String) { super.init(id) }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        firstName   = try container.decode(String.self, forKey: .firstName)
        lastName    = try container.decode(String.self, forKey: .lastName)
        age         = try container.decode(Int.self,    forKey: .age)
        email       = try container.decode(String.self, forKey: .email)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName,  forKey: .lastName)
        try container.encode(age,       forKey: .age)
        try container.encode(email,     forKey: .email)
    }
    
    private enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case age
        case email
    }
}
