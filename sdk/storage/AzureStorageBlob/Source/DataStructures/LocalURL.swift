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

/// Structure encapsulating a base-relative local filesystem URL.
public struct LocalURL {
    /// Well-known directories that are not part of the existing `FileManager.SearchPathDirectory` enum.
    public enum KnownDirectory: String {
        /// The application's temporary directory.
        case tempDirectory = "tempDir:/"

        fileprivate var realDirectory: URL {
            switch self {
            case .tempDirectory:
                return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            }
        }
    }

    // MARK: Static properties

    private static let searchPathDirectorySchemePrefix = "SearchPathDirectory."

    // MARK: Static methods

    /// Retrieve the directory and filename components for a blob within a container. Returns a tuple of (`dirName`,
    /// `fileName`), where `dirName` is the string up to, but not including, the final '/', and `fileName` is the
    /// component following the final '/'.
    /// - Parameters:
    ///   - name: The name of the blob.
    ///   - container: The name of the container
    /// - Returns: A tuple of (`dirName`, `fileName`)
    public static func pathComponents(
        forBlob name: String,
        inContainer container: String
    ) -> (dirName: String, fileName: String) {
        var defaultUrlComps = "\(container)/\(name)".split(separator: "/").compactMap { String($0) }
        let baseName = defaultUrlComps.popLast()!
        let dirName = defaultUrlComps.joined(separator: "/")
        return (dirName, baseName)
    }

    // MARK: Instance properties

    internal var rawUrl: URL

    /// The absolute URL resolved from this `LocalURL` instance. Resolution is performed by replacing the well-known
    /// directory placeholder (if present) with the current, resolved path to the well-known directory, and then
    /// appending the path components.
    public var resolvedUrl: URL? {
        let components = rawUrl.absoluteString.components(separatedBy: ":/")
        let scheme = components[0]
        let path = components[1]

        if let knownDir = KnownDirectory(rawValue: components[0] + ":/") {
            return URL(string: knownDir.realDirectory.absoluteString + path)
        } else if scheme.starts(with: LocalURL.searchPathDirectorySchemePrefix) {
            guard let rawValue = UInt(scheme.dropFirst(LocalURL.searchPathDirectorySchemePrefix.count))
            else { return nil }
            guard let directory = FileManager.SearchPathDirectory(rawValue: rawValue) else { return nil }
            guard let realDir = FileManager.default.urls(for: directory, in: .userDomainMask).first
            else { return nil }
            return URL(string: realDir.absoluteString + path)
        }
        return rawUrl
    }

    // MARK: Initializers

    /// Create a `LocalURL` from an existing absolute URL.
    public init(fromAbsoluteUrl absoluteUrl: URL) {
        self.rawUrl = absoluteUrl
    }

    /// Create a `LocalURL` for a well-known directory.
    public init(fromDirectory directory: KnownDirectory) {
        self.rawUrl = URL(string: directory.rawValue)!
    }

    /// Create a `LocalURL` for a well-known directory.
    public init(fromDirectory directory: FileManager.SearchPathDirectory) {
        self.rawUrl = URL(string: "\(LocalURL.searchPathDirectorySchemePrefix)\(directory.rawValue):/")!
    }

    /// Create a `LocalURL` for a location on the local device in which to store a blob downloaded from a container,
    /// based on a provided base directory.
    public init(basedOn baseUrl: URL, forBlob name: String, inContainer container: String) {
        self.init(fromAbsoluteUrl: baseUrl)
        appendPathComponents(forBlob: name, inContainer: container)
    }

    /// Create a `LocalURL` for a location on the local device in which to store a blob downloaded from a container,
    /// within a well-known directory.
    public init(inDirectory directory: KnownDirectory, forBlob name: String, inContainer container: String) {
        self.init(fromDirectory: directory)
        appendPathComponents(forBlob: name, inContainer: container)
    }

    /// Create a `LocalURL` for a location on the local device in which to store a blob downloaded from a container,
    /// within a well-known directory.
    public init(
        inDirectory directory: FileManager.SearchPathDirectory,
        forBlob name: String,
        inContainer container: String
    ) {
        self.init(fromDirectory: directory)
        appendPathComponents(forBlob: name, inContainer: container)
    }

    /// Append the given path component to this `LocalURL`.
    public mutating func appendPathComponent(_ pathComponent: String) {
        rawUrl.appendPathComponent(pathComponent)
    }

    /// Append the directory and filename components for a blob within a container to this `LocalURL`.
    public mutating func appendPathComponents(forBlob name: String, inContainer container: String) {
        let (dirName, fileName) = LocalURL.pathComponents(forBlob: name, inContainer: container)
        appendPathComponent(dirName)
        appendPathComponent(fileName)
    }
}
