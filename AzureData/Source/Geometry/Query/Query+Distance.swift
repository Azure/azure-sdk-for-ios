//
//  Query+Point.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreLocation

extension Query {

    // MARK: - Where

    public func `where`(distanceFrom property: String, to geometry: Geometry, isLessThan distance: CLLocationDistance) -> Query {
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")

        whereFragment = "ST_DISTANCE(\(type!).\(property), \(geometry.description)) < \(distance)"
        whereCalled = true
        spatialWhereCalled = true

        return self
    }

    public func `where`(distanceFrom property: String, to geometry: Geometry, isLessThanOrEqualTo distance: CLLocationDistance) -> Query {
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")

        whereFragment = "ST_DISTANCE(\(type!).\(property), \(geometry.description)) <= \(distance)"
        whereCalled = true
        spatialWhereCalled = true

        return self
    }

    public func `where`(distanceFrom property: String, to geometry: Geometry, is distance: CLLocationDistance) -> Query {
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")

        whereFragment = "ST_DISTANCE(\(type!).\(property), \(geometry.description)) = \(distance)"
        whereCalled = true
        spatialWhereCalled = true

        return self
    }

    public func `where`(distanceFrom property: String, to geometry: Geometry, isGreaterThan distance: CLLocationDistance) -> Query {
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")

        whereFragment = "ST_DISTANCE(\(type!).\(property), \(geometry.description)) > \(distance)"
        whereCalled = true
        spatialWhereCalled = true

        return self
    }

    public func `where`(distanceFrom property: String, to geometry: Geometry, isGreaterThanOrEqualTo distance: CLLocationDistance) -> Query {
        assert(!whereCalled, "you can only call `where` once, to add more constraints use `and`")

        whereFragment = "ST_DISTANCE(\(type!).\(property), \(geometry.description)) >= \(distance)"
        whereCalled = true
        spatialWhereCalled = true

        return self
    }

    // MARK: - And

    public func and(distanceFrom property: String, to geometry: Geometry, isLessThan distance: CLLocationDistance) -> Query {
        assert(whereCalled, "must call where before calling and")

        spatialAndFragments.append("ST_DISTANCE(\(type!).\(property), \(geometry.description)) < \(distance)")
        spatialAndCalled = true

        return self
    }

    public func and(distanceFrom property: String, to geometry: Geometry, isLessThanOrEqualTo distance: CLLocationDistance) -> Query {
        assert(whereCalled, "must call where before calling and")

        spatialAndFragments.append("ST_DISTANCE(\(type!).\(property), \(geometry.description)) <= \(distance)")
        spatialAndCalled = true

        return self
    }

    public func and(distanceFrom property: String, to geometry: Geometry, is distance: CLLocationDistance) -> Query {
        assert(whereCalled, "must call where before calling and")

        spatialAndFragments.append("ST_DISTANCE(\(type!).\(property), \(geometry.description)) = \(distance)")
        spatialAndCalled = true

        return self
    }

    public func and(distanceFrom property: String, to geometry: Geometry, isGreaterThan distance: CLLocationDistance) -> Query {
        assert(whereCalled, "must call where before calling and")

        spatialAndFragments.append("ST_DISTANCE(\(type!).\(property), \(geometry.description)) > \(distance)")
        spatialAndCalled = true

        return self
    }

    public func and(distanceFrom property: String, to geometry: Geometry, isGreaterThanOrEqualTo distance: CLLocationDistance) -> Query {
        assert(whereCalled, "must call where before calling and")

        spatialAndFragments.append("ST_DISTANCE(\(type!).\(property), \(geometry.description)) >= \(distance)")
        spatialAndCalled = true

        return self
    }
}
