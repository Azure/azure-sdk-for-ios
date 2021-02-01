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

/// The access tier of a blob.
public enum AccessTier: String, Codable, RequestStringConvertible {
    /// Hot access tier.
    case hot = "Hot"
    /// Cool access tier.
    case cool = "Cool"

    public var requestString: String {
        return rawValue
    }
}

/// The type of a blob.
public enum BlobType: String, Codable, RequestStringConvertible {
    /// Block blob.
    case block = "BlockBlob"
    /// Page blob.
    case page = "PageBlob"
    /// Append blob.
    case append = "AppendBlob"

    public var requestString: String {
        return rawValue
    }
}

/// Status of a blob copy operation.
public enum CopyStatus: String, Codable, RequestStringConvertible {
    /// Copy is in progress.
    case pending
    /// Copy completed successfully.
    case success
    /// Copy was ended by Abort Copy Blob.
    case aborted
    /// Copy failed.
    case failed

    public var requestString: String {
        return rawValue
    }
}

/// The duration of a lease on a blob or container.
public enum LeaseDuration: String, Codable, RequestStringConvertible {
    /// The lease is of infinite duration.
    case infinite
    /// The lease is of fixed duration.
    case fixed

    public var requestString: String {
        return rawValue
    }
}

/// The state of a lease on a blob or container.
public enum LeaseState: String, Codable, RequestStringConvertible {
    /// The lease is unlocked and can be acquired.
    case available
    /// The lease is locked.
    case leased
    /// The lease duration has expired.
    case expired
    /// The lease has been broken, but will continue to be locked until the break period has expired.
    case breaking
    /// The lease has been broken, and the break period has expired.
    case broken

    public var requestString: String {
        return rawValue
    }
}

/// The status of a lease on a blob or container.
public enum LeaseStatus: String, Codable, RequestStringConvertible {
    /// The lease is locked.
    case locked
    /// The lease is unlocked.
    case unlocked

    public var requestString: String {
        return rawValue
    }
}

/// Specifies the level of public access in a container
public enum PublicAccessType: String, Codable, RequestStringConvertible {
    /// Container-level access
    case container
    /// Blob-level access
    case blob

    public var requestString: String {
        return rawValue
    }
}
