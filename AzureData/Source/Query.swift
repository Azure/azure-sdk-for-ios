//
//  Query.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public class Query : Encodable {
    
    internal var selectCalled       = false
    internal var fromCalled         = false
    internal var whereCalled        = false
    internal var spatialWhereCalled = false
    internal var andCalled          = false
    internal var spatialAndCalled   = false
    internal var orderByCalled      = false
    internal var fromStringLiteral  = false

    internal var selectProperties:      [String] = []
    internal var fromFragment:          String?
    internal var whereFragment:         String?
    internal var andFragments:          [String] = []
    internal var spatialAndFragments:   [String] = []
    internal var orderByFragment:       String?
    internal var stringLiteralQuery:    String?
    
    internal var type:                  String?

    private enum CodingKeys: String, CodingKey {
        case query
        case parameters
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(query, forKey: .query)
        try container.encode(parameters.isEmpty ? [] : [parameters], forKey: .parameters)
    }
    
    internal init(_ properties: [String]? = nil) {
        selectCalled = true
        
        if let properties = properties, !properties.isEmpty {
            self.selectProperties = properties
        }
    }
    
    public static func select() -> Query {
        let query = Query()
        query.selectCalled = true

        return query
    }
    
    public static func select(_ properties: String...) -> Query {
        let query = Query()
        query.selectCalled = true
        query.selectProperties = properties

        return query
    }
    
    public static func createFrom(queryString: String) -> Query {
        let query = Query()
        query.fromStringLiteral = true
        query.stringLiteralQuery = queryString
        
        return query
    }
    
    
    public var query : String {
        
        if fromStringLiteral, let literalQuery = stringLiteralQuery, !literalQuery.isEmpty {
            return literalQuery
        }
        
        var query = ""
        
        if selectCalled && fromCalled && !type.isNilOrEmpty  {
            
            let selectFragment = selectProperties.isEmpty ? "*" : "\(type!)." + selectProperties.joined(separator: ", \(type!).")
            
            //fromFragment = type!
            
            query = "SELECT \(selectFragment) FROM \(type!)"

            if whereCalled && !whereFragment.isNilOrEmpty {
                
                query += " WHERE " + (spatialWhereCalled ? whereFragment! : "\(type!).\(whereFragment!)")
                
                if andCalled && !andFragments.isEmpty {
                    query += " AND \(type!)."
                    query += andFragments.joined(separator: " AND \(type!).")
                }

                if spatialAndCalled && !spatialAndFragments.isEmpty {
                    query += " AND "
                    query += spatialAndFragments.joined(separator: " AND ")
                }
            }
            
            if orderByCalled && !orderByFragment.isNilOrEmpty {
                
                query += " ORDER BY \(type!).\(orderByFragment!)"
            }
        }
        
        return query
    }
    
    public var parameters: [String:String] {
        return [:]
    }
    
    public var dictionary: [String: Any] {
        return [
            "query": query,
            "parameters": parameters.isEmpty ? [] : [parameters]
        ]
    }
}

extension Query {
    
    public func from(_ type: String) -> Self {
        assert(!fromStringLiteral, "`from` cannot be called on a Query created from a string literal")
        assert(selectCalled, "must call `select` before calling `from`")
        assert(!fromCalled, "you can only call `from` once")
        fromCalled = true;
        
        self.type = type
        
        return self
    }
    
    // MARK: Where
    
    public func `where`(_ property: String, is value: String) -> Self {
        assert(!fromStringLiteral, "`where` cannot be called on a Query created from a string literal")
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")
        whereCalled = true
        
        whereFragment = #"\#(property) = "\#(value)""#
        
        return self
    }
    
    public func `where`(_ property: String, is value: Int) -> Self {
        assert(!fromStringLiteral, "`where` cannot be called on a Query created from a string literal")
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")
        whereCalled = true
        
        whereFragment = "\(property) = \(value)"
        
        return self
    }
    
    public func `where`(_ property: String, isNot value: String) -> Self {
        assert(!fromStringLiteral, "`where` cannot be called on a Query created from a string literal")
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")
        whereCalled = true
        
        whereFragment = #"\#(property) != "\#(value)""#
        
        return self
    }
    
    public func `where`(_ property: String, isNot value: Int) -> Self {
        assert(!fromStringLiteral, "`where` cannot be called on a Query created from a string literal")
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")
        whereCalled = true
        
        whereFragment = "\(property) != \(value)"
        
        return self
    }
    
    public func `where`(_ property: String, isGreaterThan value: String) -> Self {
        assert(!fromStringLiteral, "`where` cannot be called on a Query created from a string literal")
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")
        whereCalled = true
        
        whereFragment = #"\#(property) > "\#(value)""#
        
        return self
    }
    
    public func `where`(_ property: String, isGreaterThan value: Int) -> Self {
        assert(!fromStringLiteral, "`where` cannot be called on a Query created from a string literal")
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")
        whereCalled = true
        
        whereFragment = "\(property) > \(value)"
        
        return self
    }
    
    public func `where`(_ property: String, isLessThan value: String) -> Self {
        assert(!fromStringLiteral, "`where` cannot be called on a Query created from a string literal")
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")
        whereCalled = true
        
        whereFragment = #"\#(property) < "\#(value)""#
        
        return self
    }
    
    public func `where`(_ property: String, isLessThan value: Int) -> Self {
        assert(!fromStringLiteral, "`where` cannot be called on a Query created from a string literal")
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")
        whereCalled = true
        
        whereFragment = "\(property) < \(value)"
        
        return self
    }
    
    public func `where`(_ property: String, is value: Bool = true) -> Self {
        assert(!fromStringLiteral, "`where` cannot be called on a Query created from a string literal")
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")
        whereCalled = true
        
        whereFragment = "\(property) = \(value)"
        
        return self
    }
    
    // MARK: And
    
    public func and(_ property: String, is value: String) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append(#"\#(property) = "\#(value)""#)
        
        return self
    }
    
    public func and(_ property: String, is value: Int) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append("\(property) = \(value)")
        
        return self
    }
    
    public func and(_ property: String, isNot value: String) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append(#"\#(property) != "\#(value)""#)
        
        return self
    }
    
    public func and(_ property: String, isNot value: Int) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append("\(property) != \(value)")
        
        return self
    }
    
    public func and(_ property: String, isGreaterThan value: String) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append(#"\#(property) > "\#(value)""#)
        
        return self
    }
    
    public func and(_ property: String, isGreaterThan value: Int) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append("\(property) > \(value)")
        
        return self
    }
    
    public func and(_ property: String, isGreaterThanOrEqualTo value: String) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append(#"\#(property) >= "\#(value)""#)
        
        return self
    }
    
    public func and(_ property: String, isGreaterThanOrEqualTo value: Int) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append("\(property) >= \(value)")
        
        return self
    }
    
    public func and(_ property: String, isLessThan value: String) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append(#"\#(property) < "\#(value)""#)
        
        return self
    }
    
    public func and(_ property: String, isLessThan value: Int) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append("\(property) < \(value)")
        
        return self
    }
    
    public func and(_ property: String, isLessThanOrEqualTo value: String) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append(#"\#(property) <= "\#(value)""#)
        
        return self
    }
    
    public func and(_ property: String, isLessThanOrEqualTo value: Int) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append("\(property) <= \(value)")
        
        return self
    }
    
    public func and(_ property: String, is value: Bool = true) -> Self {
        assert(!fromStringLiteral, "`and` cannot be called on a Query created from a string literal")
        assert(whereCalled, "must call where before calling and")
        andCalled = true
        
        andFragments.append("\(property) = \(value)")
        
        return self
    }
    
    // MARK: Order By
    
    public func orderBy(_ property: String, descending: Bool = false) -> Self {
        assert(!fromStringLiteral, "`orderBy` cannot be called on a Query created from a string literal")
        assert(!orderByCalled, "you can only call `orderBy` once, to order on an additional level use `thenBy`")
        orderByCalled = true

        orderByFragment = property
        
        if descending { orderByFragment! += " DESC" }
        
        return self
    }
}

extension Query : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(selectProperties)
        hasher.combine(fromFragment)
        hasher.combine(whereFragment)
        hasher.combine(andFragments)
        hasher.combine(orderByFragment)
    }

    public static func == (lhs: Query, rhs: Query) -> Bool {
        return lhs.type == rhs.type
            && lhs.selectProperties == rhs.selectProperties
            && lhs.fromFragment == rhs.fromFragment
            && lhs.whereFragment == rhs.whereFragment
            && lhs.andFragments == rhs.andFragments
            && lhs.orderByFragment == rhs.orderByFragment
    }
}
