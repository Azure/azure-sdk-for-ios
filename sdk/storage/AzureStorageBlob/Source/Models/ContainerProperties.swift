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

/// Structure containing properties of a blob container.
public struct ContainerProperties: XMLModel {
    /// The date the container was last modified.
    public let lastModified: Rfc1123Date
    /// The entity tag for the container.
    public let eTag: String
    /// The lease status of the container.
    public let leaseStatus: LeaseStatus
    /// The lease state of the container.
    public let leaseState: LeaseState
    /// Specifies whether the lease on a container is of infinite or fixed duration.
    public let leaseDuration: LeaseDuration?
    /// Indicates whether the container has an immutability policy set on it.
    public let hasImmutabilityPolicy: Bool?
    /// Indicates whether the container has a legal hold.
    public let hasLegalHold: Bool?

    // MARK: Initializers

    internal init(
        lastModified: Rfc1123Date,
        eTag: String,
        leaseStatus: LeaseStatus,
        leaseState: LeaseState,
        leaseDuration: LeaseDuration? = nil,
        hasImmutabilityPolicy: Bool? = nil,
        hasLegalHold: Bool? = nil
    ) {
        self.lastModified = lastModified
        self.eTag = eTag
        self.leaseStatus = leaseStatus
        self.leaseState = leaseState
        self.leaseDuration = leaseDuration
        self.hasImmutabilityPolicy = hasImmutabilityPolicy
        self.hasLegalHold = hasLegalHold
    }

    internal init?(from headers: HTTPHeaders) {
        guard let lastModified = Rfc1123Date(string: headers[HTTPHeader.lastModified]),
            let etag = headers[HTTPHeader.etag] else {
            return nil
        }
        self.lastModified = lastModified
        self.eTag = etag
        self.leaseStatus = LeaseStatus(rawValue: headers[StorageHTTPHeader.leaseStatus]) ?? .unlocked
        self.leaseState = LeaseState(rawValue: headers[StorageHTTPHeader.leaseState]) ?? .available
        self.leaseDuration = LeaseDuration(rawValue: headers[StorageHTTPHeader.leaseDuration])
        self.hasImmutabilityPolicy = Bool(headers[StorageHTTPHeader.hasImmutabilityPolicy])
        self.hasLegalHold = Bool(headers[StorageHTTPHeader.hasLegalHold])
    }

    // MARK: XMLModel Delegate

    /// :nodoc:
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

// MARK: Codable Delegate

extension ContainerProperties: Codable {
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            lastModified: try root.decode(Rfc1123Date.self, forKey: .lastModified),
            eTag: try root.decode(String.self, forKey: .eTag),
            leaseStatus: try root.decode(LeaseStatus.self, forKey: .leaseStatus),
            leaseState: try root.decode(LeaseState.self, forKey: .leaseState),
            leaseDuration: try root.decodeIfPresent(LeaseDuration.self, forKey: .leaseDuration),
            hasImmutabilityPolicy: try root.decodeBoolIfPresent(forKey: .hasImmutabilityPolicy),
            hasLegalHold: try root.decodeBoolIfPresent(forKey: .hasLegalHold)
        )
    }
}
