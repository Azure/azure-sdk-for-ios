//
//  Person.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureData

final class TestDocument: Document {
    static var partitionKey: PartitionKey? {
        return \.birthCity
    }

    let id: String
    let firstName: String
    let lastName: String
    let birthCity: String

    init(id: String, firstName: String, lastName: String, birthCity: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.birthCity = birthCity
    }
}

extension TestDocument {
    static var partitionKeyDefinition = "/birthCity"
    static func stub(_ id: String, firstName: String = "Faiçal", lastName: String = "Tchirou", birthCity: String = "Kharkov") -> TestDocument {
        return TestDocument(id: id, firstName: firstName, lastName: lastName, birthCity: birthCity)
    }
}

extension TestDocument: Equatable {
    static func == (lhs: TestDocument, rhs: TestDocument) -> Bool {
        return lhs.id == rhs.id
            && lhs.firstName == rhs.firstName
            && lhs.lastName == rhs.lastName
            && lhs.birthCity == rhs.birthCity
    }
}
