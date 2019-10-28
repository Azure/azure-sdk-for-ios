// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

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
