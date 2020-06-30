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

    func register(client: StorageBlobClient) throws

    // MARK: Queue Operations

    subscript(_: Int) -> TransferImpl { get }
    var transfers: [TransferImpl] { get }

    func add(transfer: TransferImpl)
    func cancel(transfer: TransferImpl)
    func pause(transfer: TransferImpl)
    func remove(transfer: TransferImpl)
    func resume(transfer: TransferImpl, progressHandler: ((BlobTransfer) -> Void)?)

    func loadContext()
    func save(context: NSManagedObjectContext)
}

/// A delegate to receive notifications about state changes for all transfers managed by a `StorageBlobClient`.
internal protocol TransferDelegate: AnyObject {
    /// A transfer's state and/or progress have changed.
    /// - Parameters:
    ///   - transfer: The `Transfer` object that updated.
    ///   - state: The `TransferState` of the updated transfer.
    ///   - progress: The `TransferProgress` of the updated transfer.
    func transfer(
        _ transfer: Transfer,
        didUpdateWithState state: TransferState,
        andProgress progress: TransferProgress?
    )

    /// A transfer has failed.
    /// - Parameters:
    ///   - transfer: The `Transfer` object that failed.
    ///   - error: The `Error` associated with the failure.
    func transfer(_ transfer: Transfer, didFailWithError error: Error)

    /// A transfer has finished.
    /// - Parameter transfer: The `Transfer` object that finished.
    func transferDidComplete(_ transfer: Transfer)
}
