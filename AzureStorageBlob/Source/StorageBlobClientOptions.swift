//
//  StorageBlobClientOptions.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 10/15/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import Foundation

public class ListContainersOptions: AzureOptions {
    /// Datasets which may be included as part of the call response.
    public enum ListContainersInclude: String {
        case metadata
    }

    /// Return only containers whose names begin with the specified prefix.
    public var prefix: String?

    /// One or more datasets to include in the response.
    public var include: [ListContainersInclude]?

    /// Maximum number of containers to return, up to 5000.
    public var maxResults: Int?

    /// Request timeout in seconds.
    public var timeout: Int?

    public override init() {
        super.init()
        prefix = nil
        include = nil
        maxResults = nil
        timeout = nil
    }
}

public class ListBlobsOptions: AzureOptions {
    /// Datasets which may be included as part of the call response.
    public enum ListBlobsInclude: String {
        case snapshots, metadata, uncommittedblobs, copy, deleted
    }

    /// Return only blobs whose names begin with the specified prefix.
    public var prefix: String?

    /// Operation returns a BlobPrefix element in the response body that acts as a placeholder for all
    /// blobs whose names begin with the same substring up to the appearance of the delimiter character.
    /// The delimiter may be a single charcter or a string.
    public var delimiter: String?

    /// Maximum number of containers to return, up to 5000.
    public var maxResults: Int?

    /// One or more datasets to include in the response.
    public var include: [ListBlobsInclude]?

    /// Request timeout in seconds.
    public var timeout: Int?

    public override init() {
        super.init()
        prefix = nil
        delimiter = nil
        include = nil
        maxResults = nil
        timeout = nil
    }
}
