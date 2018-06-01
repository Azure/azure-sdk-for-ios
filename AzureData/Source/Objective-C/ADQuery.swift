//
//  ADQuery.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADQuery)
public class ADQuery: NSObject {
    internal var query: Query

    @objc
    public override init() {
        self.query = Query()
        super.init()
    }

    @objc
    public func from(_ type: String) -> ADQuery {
        query = query.from(type)
        return self
    }

    @objc(where:isString:)
    public func `where`(_ property: String, is value: String) -> ADQuery {
        query = query.where(property, is: value)
        return self
    }

    @objc(where:isInt:)
    public func `where`(_ property: String, is value: Int) -> ADQuery {
        query = query.where(property, is: value)
        return self
    }

    @objc(where:isNotString:)
    public func `where`(_ property: String, isNot value: String) -> ADQuery {
        query = query.where(property, isNot: value)
        return self
    }

    @objc(where:isNotInt:)
    public func `where`(_ property: String, isNot value: Int) -> ADQuery {
        query = query.where(property, isNot: value)
        return self
    }

    @objc(where:isGreaterThanString:)
    public func `where`(_ property: String, isGreaterThan value: String) -> ADQuery {
        query = query.where(property, isGreaterThan: value)
        return self
    }

    @objc(where:isGreaterThanInt:)
    public func `where`(_ property: String, isGreaterThan value: Int) -> ADQuery {
        query = query.where(property, isGreaterThan: value)
        return self
    }

    @objc(where:isLessThanString:)
    public func `where`(_ property: String, isLessThan value: String) -> ADQuery {
        query = query.where(property, isLessThan: value)
        return self
    }

    @objc(where:isLessThanInt:)
    public func `where`(_ property: String, isLessThan value: Int) -> ADQuery {
        query = query.where(property, isLessThan: value)
        return self
    }

    @objc(and:isString:)
    public func and(_ property: String, is value: String) -> ADQuery {
        query = query.and(property, is: value)
        return self
    }

    @objc(and:isInt:)
    public func and(_ property: String, is value: Int) -> ADQuery {
        query = query.and(property, is: value)
        return self
    }

    @objc(and:isNotString:)
    public func and(_ property: String, isNot value: String) -> ADQuery {
        query = query.and(property, isNot: value)
        return self
    }

    @objc(and:isNotInt:)
    public func and(_ property: String, isNot value: Int) -> ADQuery {
        query = query.and(property, isNot: value)
        return self
    }

    @objc(and:isGreaterThanString:)
    public func and(_ property: String, isGreaterThan value: String) -> ADQuery {
        query = query.and(property, isGreaterThan: value)
        return self
    }

    @objc(and:isGreaterThanInt:)
    public func and(_ property: String, isGreaterThan value: Int) -> ADQuery {
        query = query.and(property, isGreaterThan: value)
        return self
    }

    @objc(and:isGreaterThanOrEqualToString:)
    public func and(_ property: String, isGreaterThanOrEqualTo value: String) -> ADQuery {
        query = query.and(property, isGreaterThanOrEqualTo: value)
        return self
    }

    @objc(and:isGreaterThanOrEqualToInt:)
    public func and(_ property: String, isGreaterThanOrEqualTo value: Int) -> ADQuery {
        query = query.and(property, isGreaterThanOrEqualTo: value)
        return self
    }

    @objc(and:isLessThanString:)
    public func and(_ property: String, isLessThan value: String) -> ADQuery {
        query = query.and(property, isLessThan: value)
        return self
    }

    @objc(and:isLessThanInt:)
    public func and(_ property: String, isLessThan value: Int) -> ADQuery {
        query = query.and(property, isLessThan: value)
        return self
    }

    @objc(and:isLessThanOrEqualToString:)
    public func and(_ property: String, isLessThanOrEqualTo value: String) -> ADQuery {
        query = query.and(property, isLessThanOrEqualTo: value)
        return self
    }

    @objc(and:isLessThanOrEqualToInt:)
    public func and(_ property: String, isLessThanOrEqualTo value: Int) -> ADQuery {
        query = query.and(property, isLessThanOrEqualTo: value)
        return self
    }

    @objc
    public func orderBy(_ property: String, descending: Bool = false) -> ADQuery {
        query = query.orderBy(property, descending: descending)
        return self
    }
}
