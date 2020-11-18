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

/// Structure containing data about a blob or blob snapshot.
public final class StorageError: XMLModel {
    /// The error code
    public let code: String
    /// The error message
    public let message: String

    // MARK: Initializers

    init(
        code: String,
        message: String
    ) {
        self.code = code
        self.message = message
    }

    // MARK: XMLModel Delegate

    /// :nodoc:
    public static func xmlMap() -> XMLMap {
        return XMLMap([
            "Error": XMLMetadata(jsonName: "", jsonType: .flatten),
            "Code": XMLMetadata(jsonName: "code"),
            "Message": XMLMetadata(jsonName: "message")
        ])
    }
}

// MARK: Codable Delegate

extension StorageError: Codable {
    /// :nodoc:
    public convenience init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            code: try root.decode(String.self, forKey: .code),
            message: try root.decode(String.self, forKey: .message)
        )
    }
}
