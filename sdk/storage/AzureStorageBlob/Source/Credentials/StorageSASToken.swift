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

/// A structure representing a Storage shared access signature token.
public struct StorageSASToken {
    /// The SAS token string.
    public let sasToken: String
    /// The blob endpoint this token applies to.
    public let blobEndpoint: String?
    /// The queue endpoint this token applies to
    public let queueEndpoint: String?
    /// The file endpoint this token applies to.
    public let fileEndpoint: String?
    /// The table endpoint this token applies to.
    public let tableEndpoint: String?
    /// The date at which this token becomes valid.
    public let validAt: Iso8601Date?
    /// The date at which this token expires.
    public let expiredAt: Iso8601Date?
    /// Permissions granted by this token.
    public let permissions: StorageSASTokenPermissions

    /// Whether this token is currently valid.
    public var valid: Bool {
        guard let validAt = validAt, let expiredAt = expiredAt else { return false }
        let now = Iso8601Date()
        return now >= validAt && now < expiredAt
    }

    // MARK: Initializers

    /// Initialize a SAS token object.
    /// - Parameters:
    ///   - sasToken: The SAS token string.
    ///   - blobEndpoint: The blob endpoint this token applies to.
    ///   - queueEndpoint: The queue endpoint this token applies to.
    ///   - fileEndpoint: The file endpoint this token applies to.
    ///   - tableEndpoint: The table endpoint this token applies to.
    public init(
        sasToken: String,
        blobEndpoint: String? = nil,
        queueEndpoint: String? = nil,
        fileEndpoint: String? = nil,
        tableEndpoint: String? = nil
    ) {
        self.sasToken = sasToken
        self.blobEndpoint = blobEndpoint
        self.queueEndpoint = queueEndpoint
        self.fileEndpoint = fileEndpoint
        self.tableEndpoint = tableEndpoint

        let comps = URLComponents(string: "?\(sasToken)")
        self.validAt = Iso8601Date(string: comps?.queryItems?.first { $0.name == "st" }?.value)
        self.expiredAt = Iso8601Date(string: comps?.queryItems?.first { $0.name == "se" }?.value)
        self.permissions = StorageSASToken.parsePermissions(fromQueryItems: comps?.queryItems)
    }

    // MARK: Private methods

    private static func parsePermissions(fromQueryItems queryItems: [URLQueryItem]?) -> StorageSASTokenPermissions {
        var containerPerms: Set<StorageSASTokenContainerPermissions> = []
        var blobPerms: Set<StorageSASTokenBlobPermissions> = []
        var forContainer = false
        var forBlob = false

        guard let queryItems = queryItems,
            let perms = (queryItems.first { $0.name == "sp" }?.value)
        else { return StorageSASTokenPermissions(blob: blobPerms, container: containerPerms) }

        if let context = (queryItems.first { $0.name == "srt" }?.value) {
            // Account level
            forContainer = context.contains("c") // container
            forBlob = context.contains("o") // object
        } else if let context = (queryItems.first { $0.name == "sr" }?.value) {
            // Blob or container level
            if context == "c" { // container
                forContainer = true
            } else if context == "b" { // blob
                forBlob = true
            }
        }

        for permCharacter in perms {
            if forContainer, let permission = StorageSASTokenContainerPermissions(rawValue: permCharacter) {
                containerPerms.insert(permission)
            }
            if forBlob, let permission = StorageSASTokenBlobPermissions(rawValue: permCharacter) {
                blobPerms.insert(permission)
            }
        }

        return StorageSASTokenPermissions(blob: blobPerms, container: containerPerms)
    }
}

/// Permissions that apply to blob-level operations.
public enum StorageSASTokenBlobPermissions: Character {
    case read = "r"
    case add = "a"
    case create = "c"
    case write = "w"
    case tags = "t"
    case delete = "d"
    case deleteVersion = "x"

    /// A set containing all blob-level permissions.
    public static let all: Set<Self> = [.read, .add, .create, .write, .tags, .delete, .deleteVersion]
}

/// Permissions that apply to container-level operations.
public enum StorageSASTokenContainerPermissions: Character {
    case read = "r"
    case add = "a"
    case create = "c"
    case write = "w"
    case tags = "t"
    case delete = "d"
    case list = "l"

    /// A set containing all container-level permissions.
    public static let all: Set<Self> = [.read, .add, .create, .write, .tags, .delete, .list]
}

/// Permissions granted by a Storage shared access signature token.
public struct StorageSASTokenPermissions {
    /// Permissions that apply to blob-level operations.
    public let blob: Set<StorageSASTokenBlobPermissions>
    /// Permissions that apply to container-level operations.
    public let container: Set<StorageSASTokenContainerPermissions>

    /// A `SASTokenPermissions` object containing all blob- and container-level permissions.
    public static let all: Self = StorageSASTokenPermissions(
        blob: StorageSASTokenBlobPermissions.all,
        container: StorageSASTokenContainerPermissions.all
    )

    /// Whether this `SASTokenPermissions`'s permissions are a superset of another.
    /// - Parameters:
    ///   - other: The other `SASTokenPermissions` to compare.
    public func permits(other: Self) -> Bool {
        return other.blob.isSubset(of: blob) && other.container.isSubset(of: container)
    }
}
