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

internal struct BlobLookupList: XMLModel {
    public var committed: [String]?
    public var uncommitted: [String]?
    public var latest: [String]?

    // MARK: XMLModel Delegate

    public static func xmlMap() -> XMLMap {
        return XMLMap([
            "Committed": XMLMetadata(jsonName: "committed"),
            "Uncommitted": XMLMetadata(jsonName: "uncommitted"),
            "Latest": XMLMetadata(jsonName: "latest")
        ])
    }

    public func asXmlString(encoding: String.Encoding = .utf8) throws -> String {
        guard encoding == .utf8 else {
            throw AzureError.client("Unsupported encoding: \(encoding.description)")
        }
        var lines = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>", "<BlockList>"]
        // This will only serialize the "latest" list. This is a carryover from Python
        // Should it be changed?
        for blockId in latest ?? [] {
            lines.append("<Latest>\(blockId)</Latest>")
        }
        lines.append("</BlockList>")
        let xmlString = lines.joined(separator: "\n")
        return xmlString
    }
}

// MARK: Codable Delegate

extension BlobLookupList: Codable {
    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            committed: try root.decodeIfPresent([String].self, forKey: .committed),
            uncommitted: try root.decodeIfPresent([String].self, forKey: .uncommitted),
            latest: try root.decodeIfPresent([String].self, forKey: .latest)
        )
    }
}
