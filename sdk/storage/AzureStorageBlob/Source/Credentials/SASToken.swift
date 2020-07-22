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

/// A structure representing a Storage shared access signature token.
public struct SASToken {
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
    public let validAt: Date?
    /// The date at which this token expires.
    public let expiredAt: Date?
    /// Permissions granted by this token.
    public let permissions: SASTokenPermissions

    /// Whether this token is currently valid.
    public var valid: Bool {
        guard let validAt = validAt, let expiredAt = expiredAt else { return false }
        let now = Date()
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
        self.validAt = Date(comps?.queryItems?.filter { $0.name == "st" }.first?.value, format: .iso8601)
        self.expiredAt = Date(comps?.queryItems?.filter { $0.name == "se" }.first?.value, format: .iso8601)
        self.permissions = SASToken.parsePermissions(fromQueryItems: comps?.queryItems)
    }

    // MARK: Private methods

    private static func parsePermissions(fromQueryItems queryItems: [URLQueryItem]?) -> SASTokenPermissions {
        var containerPerms: Set<SASTokenContainerPermissions> = []
        var blobPerms: Set<SASTokenBlobPermissions> = []
        var forContainer = false
        var forBlob = false

        guard let queryItems = queryItems,
            let perms = (queryItems.filter { $0.name == "sp" }.first?.value)
        else { return SASTokenPermissions(blob: blobPerms, container: containerPerms) }

        if let context = (queryItems.filter { $0.name == "srt" }.first?.value) {
            // Account level
            forContainer = context.contains("c") // container
            forBlob = context.contains("o") // object
        } else if let context = (queryItems.filter { $0.name == "sr" }.first?.value) {
            // Blob or container level
            if context == "c" { // container
                forContainer = true
            } else if context == "b" { // blob
                forBlob = true
            }
        }

        for permCharacter in perms {
            if forContainer, let permission = SASTokenContainerPermissions(rawValue: permCharacter) {
                containerPerms.insert(permission)
            }
            if forBlob, let permission = SASTokenBlobPermissions(rawValue: permCharacter) {
                blobPerms.insert(permission)
            }
        }

        return SASTokenPermissions(blob: blobPerms, container: containerPerms)
    }
}

/// Permissions that apply to blob-level operations.
public enum SASTokenBlobPermissions: Character {
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
public enum SASTokenContainerPermissions: Character {
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
public struct SASTokenPermissions {
    /// Permissions that apply to blob-level operations.
    public let blob: Set<SASTokenBlobPermissions>
    /// Permissions that apply to container-level operations.
    public let container: Set<SASTokenContainerPermissions>

    /// A `SASTokenPermissions` object containing all blob- and container-level permissions.
    public static let all: SASTokenPermissions = SASTokenPermissions(
        blob: SASTokenBlobPermissions.all,
        container: SASTokenContainerPermissions.all
    )

    /// Whether this `SASTokenPermissions`'s permissions are a superset of another.
    /// - Parameters:
    ///   - other: The other `SASTokenPermissions` to compare.
    public func permits(other: SASTokenPermissions) -> Bool {
        return other.blob.isSubset(of: blob) && other.container.isSubset(of: container)
    }
}
