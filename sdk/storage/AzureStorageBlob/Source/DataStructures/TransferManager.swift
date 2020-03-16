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

public protocol TransferManager: ResumableOperationQueueDelegate {
    // MARK: Properties

    var reachability: ReachabilityManager? { get }
    var persistentContainer: NSPersistentContainer? { get }
    static var shared: Self { get }
    var logger: ClientLogger { get set }

    // MARK: Storage Methods

    // TODO: Uplevel the relelvant func signatures into TM protocol once reviewed
    // func upload(_ url: URL) -> Transferable
    // func download(_ url: URL) -> Transferable
    // func copy(from source: URL, to destination: URL) -> Transferable

    // MARK: Queue Operations

    var count: Int { get }
    subscript(_: Int) -> Transfer { get }

    func add(transfer: Transfer)
    func cancel(transfer: Transfer)
    func pause(transfer: Transfer)
    func remove(transfer: Transfer)
    func removeAll()
    func resume(transfer: Transfer)
    func loadContext()
    func saveContext()
}

public protocol TransferManagerDelegate: AnyObject {
    func transferManager<T: TransferManager>(
        _ manager: T,
        didUpdateTransfer transfer: Transfer,
        withState state: TransferState,
        andProgress progress: TransferProgress?
    )
    func transferManager<T: TransferManager>(
        _ manager: T,
        didUpdateTransfers transfers: [Transfer],
        withState state: TransferState
    )
    func transferManager<T: TransferManager>(_ manager: T, didCompleteTransfer transfer: Transfer)
    func transferManager<T: TransferManager>(_ manager: T, didFailTransfer transfer: Transfer, withError: Error)
    func transferManager<T: TransferManager>(_ manager: T, didUpdateWithState state: TransferState)
}

// MARK: Extensions

extension TransferManagerDelegate {
    func transferManager<T: TransferManager>(
        _ manager: T,
        didUpdateTransfer transfer: Transfer,
        withState state: TransferState
    ) {
        transferManager(manager, didUpdateTransfer: transfer, withState: state, andProgress: nil)
    }

    func transferManager<T: TransferManager>(
        _ manager: T,
        didUpdateTransfer _: Transfer,
        withState _: TransferState,
        andPorgress _: TransferProgress?
    ) {}
    func transferManager<T: TransferManager>(
        _ manager: T,
        didUpdateTransfers _: [Transfer],
        withState _: TransferState
    ) {}
    func transferManager<T: TransferManager>(_ manager: T, didCompleteTransfer _: Transfer) {}
    func transferManager<T: TransferManager>(_ manager: T, didFailTransfer _: Transfer, withError _: Error) {}
    func transferManager<T: TransferManager>(_ manager: T, didUpdateWithState _: TransferState) {}
}
