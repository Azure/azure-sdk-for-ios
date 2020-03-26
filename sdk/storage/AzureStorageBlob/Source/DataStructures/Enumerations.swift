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

public enum TransferState: Int16 {
    case pending, inProgress, paused, complete, failed, canceled, deleted

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

    public var pauseable: Bool {
        switch self {
        case .pending, .inProgress:
            return true
        case .paused, .complete, .canceled, .deleted, .failed:
            return false
        }
    }

    public var resumable: Bool {
        switch self {
        case .paused, .failed:
            return true
        case .pending, .inProgress, .complete, .canceled, .deleted:
            return false
        }
    }
}

public enum TransferType: Int16 {
    case upload, download

    public var label: String {
        switch self {
        case .upload:
            return "upload"
        case .download:
            return "download"
        }
    }
}
