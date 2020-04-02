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

/// Helper containing properties and values to aid in constructing local paths for downloading blobs.
public struct LocalPathHelper {
    /// The application's temporary directory.
    public static let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

    /// The application's cache directory.
    public static let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

    /// Retrieve a URL for a location on the local device in which to store a blob downloaded from a container.
    /// - Parameters:
    ///   - directoryURL: The base directory to construct the path within. The default is the application's cache
    ///     directory.
    ///   - name: The name of the blob.
    ///   - container: The name of the container.
    public static func url(
        inDirectory directoryURL: URL = cacheDir,
        forBlob name: String,
        inContainer container: String
    ) -> URL {
        let (dirName, fileName) = pathComponents(forBlob: name, inContainer: container)
        return directoryURL.appendingPathComponent(dirName).appendingPathComponent(fileName)
    }

    /// Retrieve the directory and filename components for a blob within a container. Returns a tuple of (`dirName`,
    /// `fileName`), where `dirName` is the string up to, but not including, the final '/', and `fileName` is the
    /// component following the final '/'.
    /// - Parameters:
    ///   - name: The name of the blob.
    ///   - container: The name of the container
    /// - Returns: A tuple of (`dirName`, `fileName`)
    public static func pathComponents(forBlob name: String, inContainer container: String) -> (String, String) {
        var defaultUrlComps = "\(container)/\(name)".split(separator: "/").compactMap { String($0) }
        let baseName = defaultUrlComps.popLast()!
        let dirName = defaultUrlComps.joined(separator: "/")
        return (dirName, baseName)
    }
}
