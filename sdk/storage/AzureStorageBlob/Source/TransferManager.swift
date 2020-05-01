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
    func transfer(_ transfer: Transfer, didUpdateWithState state: TransferState, andProgress progress: Float?)
    /// A batch of transfers have changed.
    func transfersDidUpdate(_ tranfers: [Transfer])
    /// A transfer has failed.
    func transfer(_ transfer: Transfer, didFailWithError error: Error)
    /// A transfer has completed.
    func transferDidComplete(_ transfer: Transfer)
}
