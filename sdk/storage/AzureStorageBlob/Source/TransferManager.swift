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
import CoreData

// MARK: Protocols

internal protocol TransferManager {
    // MARK: Properties

    var maxConcurrency: Int { get set }
    var persistentContainer: NSPersistentContainer { get }

    // MARK: Lifecycle Methods

    func register(client: StorageBlobClient?, forRestorationId: String) throws
    func startManaging()
    func stopManaging()

    // MARK: Queue Operations

    subscript(_: Int) -> TransferImpl { get }
    var transfers: [TransferImpl] { get }

    func add(transfer: TransferImpl)
    func cancel(transfer: TransferImpl)
    func cancelAll(withRestorationId: String?)
    func pause(transfer: TransferImpl)
    func pauseAll(withRestorationId: String?)
    func remove(transfer: TransferImpl)
    func removeAll(withRestorationId: String?)
    func resume(transfer: TransferImpl)
    func resumeAll(withRestorationId: String?)

    func loadContext()
    func save(context: NSManagedObjectContext)
}

/// A delegate to receive notifications about state changes for all transfers managed by a `StorageBlobClient`.
public protocol TransferDelegate: AnyObject {
    /// A transfer's state has changed, and progress may be reported.
    func transfer(_: Transfer, didUpdateWithState: TransferState, andProgress: Float?)
    /// A batch of transfers have changed.
    func transfersDidUpdate(_: [Transfer])
    /// A transfer has failed.
    func transfer(_: Transfer, didFailWithError: Error)
    /// A transfer has completed.
    func transferDidComplete(_: Transfer)
}

// MARK: Extensions

public extension Array where Element == Transfer {
    /// Retrieve a single Transfer object by its id.
    /// - Parameters:
    ///   - id: The id of the transfer to retrieve.
    func element(withId id: UUID) -> Transfer? {
        return first { $0.id == id }
    }

    /// Retrieve all download transfers where the source container and blob match the provided parameters.
    /// - Parameters:
    ///   - container: The name of the download's source container.
    ///   - blob: The name of the download's source blob.
    func downloadedFrom(container: String, blob: String) -> [BlobTransfer] {
        let pathSuffix = "\(container)/\(blob)"
        return compactMap { transfer in
            guard let transfer = transfer as? BlobTransfer, let source = transfer.source else { return nil }
            return transfer.transferType == .download && source.path.hasSuffix(pathSuffix) ? transfer : nil
        }
    }

    /// Retrieve all download transfers where the destination matches the provided destination URL.
    /// - Parameters:
    ///   - destinationUrl: The URL to a file path on this device which is the destination of the download.
    func downloadedTo(file destinationUrl: URL) -> [BlobTransfer] {
        return compactMap { transfer in
            guard let transfer = transfer as? BlobTransfer else { return nil }
            return transfer.transferType == .download && transfer.destination == destinationUrl ? transfer : nil
        }
    }

    /// Retrieve all upload transfers where the source matches the provided source URL.
    /// - Parameters:
    ///   - sourceUrl: The URL to a file on this device which is the source of the upload.
    func uploadedFrom(file sourceUrl: URL) -> [BlobTransfer] {
        return compactMap { transfer in
            guard let transfer = transfer as? BlobTransfer else { return nil }
            return transfer.transferType == .upload && transfer.source == sourceUrl ? transfer : nil
        }
    }

    /// Retrieve all upload transfers where the destination container and blob match the provided parameters.
    /// - Parameters:
    ///   - container: The name of the upload's destination container.
    ///   - blob: The name of the upload's destination blob.
    func uploadedTo(container: String, blob: String) -> [BlobTransfer] {
        let pathSuffix = "\(container)/\(blob)"
        return compactMap { transfer in
            guard let transfer = transfer as? BlobTransfer, let destination = transfer.destination else { return nil }
            return transfer.transferType == .upload && destination.path.hasSuffix(pathSuffix) ? transfer : nil
        }
    }
}
