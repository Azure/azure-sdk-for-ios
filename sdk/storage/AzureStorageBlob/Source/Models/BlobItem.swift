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
public struct BlobItem: XMLModel {
    /// The name of the blob or snapshot.
    public let name: String
    /// Indicates if the blob or snapshot is soft-deleted.
    public let deleted: Bool?
    /// The date this snapshot was created.
    public let snapshot: Date?
    /// The blob or snapshot's associated metadata.
    public let metadata: [String: String]?
    /// Properties applied to the blob or snapshot.
    public let properties: BlobProperties?

    // MARK: XMLModel Delegate

    /// :nodoc:
    public static func xmlMap() -> XMLMap {
        return XMLMap([
            "Name": XMLMetadata(jsonName: "name"),
            "Deleted": XMLMetadata(jsonName: "deleted"),
            "Snapshot": XMLMetadata(jsonName: "snapshot"),
            "Metadata": XMLMetadata(jsonName: "metadata", jsonType: .anyObject),
            "Properties": XMLMetadata(jsonName: "properties", jsonType: .object(BlobProperties.self))
        ])
    }
}

// MARK: Codable Delegate

extension BlobItem: Codable {
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try root.decode(String.self, forKey: .name),
            deleted: try root.decodeBoolIfPresent(forKey: .deleted),
            snapshot: try root.decodeIfPresent(Date.self, forKey: .snapshot),
            metadata: try root.decodeIfPresent([String: String].self, forKey: .metadata),
            properties: try root.decodeIfPresent(BlobProperties.self, forKey: .properties)
        )
    }
}
