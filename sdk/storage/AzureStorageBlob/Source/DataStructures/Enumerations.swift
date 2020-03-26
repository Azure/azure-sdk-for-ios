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

import Foundation

/// The access tier of a blob.
public enum AccessTier: String, Codable {
    /// Hot access tier.
    case hot
    /// Cold access tier.
    case cold
}

/// The type of a blob.
public enum BlobType: String, Codable {
    /// Block blob.
    case block = "BlockBlob"
    /// Page blob.
    case page = "PageBlob"
    /// Append blob.
    case append = "AppendBlob"
}

/// Status of a blob copy operation.
public enum CopyStatus: String, Codable {
    /// Copy is in progress.
    case pending
    /// Copy completed successfully.
    case success
    /// Copy was ended by Abort Copy Blob.
    case aborted
    /// Copy failed.
    case failed
}

/// The duration of a lease on a blob or container.
public enum LeaseDuration: String, Codable {
    /// The lease is of infinite duration.
    case infinite
    /// The lease is of fixed duration.
    case fixed
}

/// The state of a lease on a blob or container.
public enum LeaseState: String, Codable {
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
}

/// The status of a lease on a blob or container.
public enum LeaseStatus: String, Codable {
    /// The lease is locked.
    case locked
    /// The lease is unlocked.
    case unlocked
}

/// The state of a transfer.
public enum TransferState: Int16 {
    /// The transfer has not been started by the transfer management engine.
    case pending
    /// The transfer is currently in progress.
    case inProgress
    /// The transfer is paused.
    case paused
    /// The transfer completed successfully.
    case complete
    /// The transfer failed. This failure may or may not be retryable.
    case failed
    /// The transfer was explicitly canceled.
    case canceled
    /// The record of the transfer no longer exists.
    case deleted

    /// A string representation of the transfer state.
    public var label: String {
        switch self {
        case .pending:
            return "Pending"
        case .inProgress:
            return "In Progress"
        case .paused:
            return "Paused"
        case .complete:
            return "Complete"
        case .failed:
            return "Failed"
        case .canceled:
            return "Canceled"
        case .deleted:
            return "Deleted"
        }
    }

    /// Indicates whether the transfer is currently in a state that can be paused.
    public var pauseable: Bool {
        switch self {
        case .pending, .inProgress:
            return true
        case .paused, .complete, .canceled, .deleted, .failed:
            return false
        }
    }

    /// Indicates whether the transfer is currently in a state that can be resumed.
    public var resumable: Bool {
        switch self {
        case .paused, .failed:
            return true
        case .pending, .inProgress, .complete, .canceled, .deleted:
            return false
        }
    }

    /// Indicates whether the transfer is currently in an active state.
    public var active: Bool {
        switch self {
        case .pending, .inProgress:
            return true
        case .paused, .failed, .complete, .canceled, .deleted:
            return false
        }
    }
}

/// The type of a transfer.
public enum TransferType: Int16 {
    /// A blob upload.
    case upload
    /// A blob download.
    case download

    /// A string representation of the transfer type.
    public var label: String {
        switch self {
        case .upload:
            return "upload"
        case .download:
            return "download"
        }
    }
}
