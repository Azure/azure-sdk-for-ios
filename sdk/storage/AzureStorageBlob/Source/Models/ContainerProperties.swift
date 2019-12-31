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

public final class ContainerProperties: XMLModelProtocol {
    public let lastModified: Date
    public let eTag: String
    public let leaseStatus: LeaseStatus
    public let leaseState: LeaseState
    public let leaseDuration: LeaseDuration?
    public let hasImmutabilityPolicy: Bool?
    public let hasLegalHold: Bool?

    public init(lastModified: Date,
                eTag: String,
                leaseStatus: LeaseStatus,
                leaseState: LeaseState,
                leaseDuration: LeaseDuration? = nil,
                hasImmutabilityPolicy: Bool? = nil,
                hasLegalHold: Bool? = nil) {
        self.lastModified = lastModified
        self.eTag = eTag
        self.leaseStatus = leaseStatus
        self.leaseState = leaseState
        self.leaseDuration = leaseDuration
        self.hasImmutabilityPolicy = hasImmutabilityPolicy
        self.hasLegalHold = hasLegalHold
    }

    public static func xmlMap() -> XMLMap {
        return XMLMap([
            "Last-Modified": XMLMetadata(jsonName: "lastModified"),
            "Etag": XMLMetadata(jsonName: "eTag"),
            "LeaseStatus": XMLMetadata(jsonName: "leaseStatus"),
            "LeaseState": XMLMetadata(jsonName: "leaseState"),
            "LeaseDuration": XMLMetadata(jsonName: "leaseDuration"),
            "HasImmutabilityPolicy": XMLMetadata(jsonName: "hasImmutabilityPolicy"),
            "HasLegalHold": XMLMetadata(jsonName: "hasLegalHold")
        ])
    }
}

extension ContainerProperties: Codable {
    public convenience init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            lastModified: try root.decode(Date.self, forKey: .lastModified),
            eTag: try root.decode(String.self, forKey: .eTag),
            leaseStatus: try root.decode(LeaseStatus.self, forKey: .leaseStatus),
            leaseState: try root.decode(LeaseState.self, forKey: .leaseState),
            leaseDuration: try root.decodeIfPresent(LeaseDuration.self, forKey: .leaseDuration),
            hasImmutabilityPolicy: try root.decodeBoolIfPresent(forKey: .hasImmutabilityPolicy),
            hasLegalHold: try root.decodeBoolIfPresent(forKey: .hasLegalHold)
        )
    }
}
