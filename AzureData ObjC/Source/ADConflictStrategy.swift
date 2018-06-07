//
//  ADConflictStrategy.swift
//  AzureData ObjC
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public typealias ADConflictResolver = (_ local: ADResource, _ remote: ADResource) -> ADResource

@objc(ADConflictStrategy)
public class ADConflictStrategy: NSObject {
}

@objc(ADNoConflictStrategy)
public class ADNoConflictStrategy: ADConflictStrategy {
}

@objc(ADOverwriteConflictStrategy)
public class ADOverwriteConflictStrategy: ADConflictStrategy {
}

@objc(ADCustomConflictStrategy)
public class ADCustomConflictStrategy: ADConflictStrategy {
    @objc
    public var resolver: ADConflictResolver

    @objc(initWithResolver:)
    public init(resolver: @escaping ADConflictResolver) {
        self.resolver = resolver
    }
}

extension ConflictStrategy {
    var bridgedToObjectiveC: ADConflictStrategy {
        switch self {
        case .none:
            return ADNoConflictStrategy()
        case .overwrite:
            return ADOverwriteConflictStrategy()
        case .custom(let resolver):
            return ADCustomConflictStrategy(resolver: { local, remote in
                return CodableResourceObjectiveWrapper(resolver(ADResourceSwiftWrapper(local), ADResourceSwiftWrapper(remote)))
            })
        }
    }

    init(bridgedFromObjectiveC: ADConflictStrategy) {
        switch bridgedFromObjectiveC {
        case is ADNoConflictStrategy:
            self = .none
        case is ADOverwriteConflictStrategy:
            self = .overwrite
        case let strategy as ADCustomConflictStrategy:
            self = .custom({ local, remote in
                return ADResourceSwiftWrapper(strategy.resolver(CodableResourceObjectiveWrapper(local), CodableResourceObjectiveWrapper(remote)))
            })
        default:
            self = .none
        }
    }
}
