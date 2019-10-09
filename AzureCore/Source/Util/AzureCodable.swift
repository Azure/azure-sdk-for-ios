//
//  AzureCodable.swift
//  AzureCore
//
//  Created by Travis Prescott on 10/8/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    public func decodeBool(forKey key: K) throws -> Bool {
        do {
            return try decode(Bool.self, forKey: key)
        } catch let DecodingError.typeMismatch(expectedType, context) {
            let mismatchError = DecodingError.typeMismatch(expectedType, context)
            guard let stringValue = try? self.decode(String.self, forKey: key) else { throw mismatchError }
            guard let boolVal = Bool(stringValue) else { throw mismatchError }
            return boolVal
        }
    }

    public func decodeBoolIfPresent(forKey key: K) throws -> Bool? {
        do {
            return try decodeIfPresent(Bool.self, forKey: key)
        } catch let DecodingError.typeMismatch(expectedType, context) {
            let mismatchError = DecodingError.typeMismatch(expectedType, context)
            guard let stringValue = try? self.decode(String.self, forKey: key) else { throw mismatchError }
            guard let boolVal = Bool(stringValue) else { throw mismatchError }
            return boolVal
        }
    }

    public func decodeInt(forKey key: K) throws -> Int {
        do {
            return try decode(Int.self, forKey: key)
        } catch let DecodingError.typeMismatch(expectedType, context) {
            let mismatchError = DecodingError.typeMismatch(expectedType, context)
            guard let stringValue = try? self.decode(String.self, forKey: key) else { throw mismatchError }
            guard let intVal = Int(stringValue) else { throw mismatchError }
            return intVal
        }
    }

    public func decodeIntIfPresent(forKey key: K) throws -> Int? {
        do {
            return try decodeIfPresent(Int.self, forKey: key)
        } catch let DecodingError.typeMismatch(expectedType, context) {
            let mismatchError = DecodingError.typeMismatch(expectedType, context)
            guard let stringValue = try? self.decode(String.self, forKey: key) else { throw mismatchError }
            guard let intVal = Int(stringValue) else { throw mismatchError }
            return intVal
        }
    }
}
