//
//  Enumerations.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 10/7/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public enum AccessTier: String, Codable {
    case hot, cold
}

public enum BlobType: String, Codable {
    case block = "BlockBlob"
    case page = "PageBlob"
    case append = "AppendBlob"
}

public enum CopyStatus: String, Codable {
    case pending, success, aborted, failed
}

public enum LeaseDuration: String, Codable {
    case infinite, fixed
}

public enum LeaseState: String, Codable {
    case available, leased, expired, breaking, broken
}

public enum LeaseStatus: String, Codable {
    case locked, unlocked
}

