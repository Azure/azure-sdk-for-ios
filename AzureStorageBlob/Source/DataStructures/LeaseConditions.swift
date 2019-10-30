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

public struct LeaseAccessConditions {
    public var leaseId: String
}

public struct ModifiedAccessConditions {
    public var ifModifiedSince: Date?
    public var ifUnmodifiedSince: Date?
    public var ifMatch: String?
    public var ifNoneMatch: String?
}

public struct RangeOptions {

    /// Start of byte range to use for downloading a section of the blob.
    /// Must be set if length is provided.
    public var offset = 0

    /// Number of bytes to read from the stream. Should be specified
    /// for optimal performance.
    public var length: Int? = nil

    /// When set to true, the service returns the MD5 hash for the range
    /// as long as the range is less than or equal to 4 MB in size.
    public var calculateMD5: Bool? = nil

    /// When set to true, the service returns the CRC64 hash for the range
    /// as long as the range is less than or equal to 4 MB in size.
    public var calculateCRC64: Bool? = nil

    public init() {}
}
