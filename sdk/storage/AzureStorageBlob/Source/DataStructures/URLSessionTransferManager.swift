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

public final class URLSessionTransferManager: NSObject, TransferManager, URLSessionTaskDelegate {
    // MARK: Type Aliase

    public typealias TransferManagerType = URLSessionTransferManager

    // MARK: Properties

    public weak var delegate: TransferManagerDelegate?

    public var logger: ClientLogger

    internal lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.azuresdk.transfermanager")
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    public lazy var reachability: ReachabilityManager? = {
        var manager = ReachabilityManager()
        manager?.registerListener { status in
            switch status {
            case .unknown, .notReachable:
                for transfer in self.transfers {
                    self.pause(transfer: transfer)
                }
            case .reachable(.ethernetOrWiFi), .reachable(.wwan):
                let pausedTransfers = self.transfers.filter { $0.state == .paused }
                for transfer in pausedTransfers {
                    self.resume(transfer: transfer)
                }
            default:
                break
            }
        }
        return manager
    }()

    internal var operationQueue: ResumableOperationQueue

    internal var transfers: [Transfer]

    public var count: Int {
        return transfers.count
    }

    public var persistentContainer: NSPersistentContainer? = {
        guard let bundle = Bundle(identifier: "com.azure.storage.AzureStorageBlob") else { return nil }
        guard let url = bundle.url(forResource: "AzureStorage", withExtension: "momd") else { return nil }
        guard let model = NSManagedObjectModel(contentsOf: url) else { return nil }
        let container = NSPersistentContainer(name: "AzureSDKTransferManager", managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: Initializers

    public init(delegate: TransferManagerDelegate? = nil, logger: ClientLogger? = nil) {
        self.delegate = delegate
        self.logger = logger ?? PrintLogger(tag: "StorageTransferManager", level: .debug)
        self.operationQueue = ResumableOperationQueue(name: "TransferQueue", delegate: nil, removeOnCompletion: true)
        self.transfers = [Transfer]()

        super.init()
        operationQueue.delegate = self
        operationQueue.maxConcurrentOperationCount = 2
    }

    // Static Singleton
    public static var shared: URLSessionTransferManager = {
        let shared = URLSessionTransferManager(delegate: nil)
        return shared
    }()

    // MARK: TransferManager Methods

    public subscript(index: Int) -> Transfer {
        // return the operation from the DataStore
        return transfers[index]
    }

    // MARK: Add Operations

    public func add(transfer: Transfer) {
        switch transfer {
        case let transfer as BlockTransfer:
            add(transfer: transfer)
        case let transfer as BlobTransfer:
            add(transfer: transfer)
        default:
            fatalError("Unexpected operation type: \(transfer.self)")
        }
    }

    internal func add(transfer: BlockTransfer) {
        // Add to DataStore
        transfers.append(transfer)

        // Add to OperationQueue and notify delegate
        let operation = BlockOperation(withTransfer: transfer)
        operationQueue.add(operation)
        self.operation(operation, didChangeState: transfer.state)
    }

    internal func queueOperationsFor(blobTransfer transfer: BlobTransfer) {
        let disallowed: [TransferState] = [.complete, .canceled, .failed]
        let resumableOperations: [TransferState] = [.pending, .inProgress]
        guard !disallowed.contains(transfer.state) else { return }
        var operations = [ResumableTransfer]()

        switch transfer.transferType {
        case .download:
            let finalOperation = BlobDownloadFinalOperation(withTransfer: transfer, queue: operationQueue)
            operations.append(finalOperation)
            let pendingTransfers = transfer.transfers.filter { resumableOperations.contains($0.state) }
            let initialOperation = BlobDownloadInitialOperation(withTransfer: transfer, queue: operationQueue)
            operations.append(initialOperation)
            for blockTransfer in pendingTransfers {
                let blockOperation = BlockOperation(withTransfer: blockTransfer)
                blockOperation.addDependency(initialOperation)
                finalOperation.addDependency(blockOperation)
                operations.append(blockOperation)
            }
        case .upload:
            let finalOperation = BlobUploadFinalOperation(withTransfer: transfer, queue: operationQueue)
            operations.append(finalOperation)
            let pendingTransfers = transfer.transfers.filter { resumableOperations.contains($0.state) }
            for blockTransfer in pendingTransfers {
                let blockOperation = BlockOperation(withTransfer: blockTransfer)
                finalOperation.addDependency(blockOperation)
                operations.append(blockOperation)
            }
        case .unknown:
            // Unknown transfers are invalid
            remove(transfer: transfer)
        }
        operationQueue.add(operations)
        self.operations(operations, didChangeState: transfer.state)
    }

    internal func add(transfer: BlobTransfer) {
        guard let context = persistentContainer?.viewContext else { return }

        // Add to DataStore
        transfers.append(transfer)

        if transfer.transfers.isEmpty, transfer.state == .pending {
            switch transfer.transferType {
            case .download:
                let blockTransfer = BlockTransfer.with(context: context, startRange: 0, endRange: 1, parent: transfer)
                transfer.blocks?.adding(blockTransfer)
            case .upload:
                guard let uploader = transfer.uploader else { return }
                for (range, blockId) in uploader.blockList {
                    let blockTransfer = BlockTransfer
                        .with(
                            context: context,
                            blockId: blockId,
                            startRange: Int64(range.startIndex),
                            endRange: Int64(range.endIndex),
                            parent: transfer
                        )
                    transfer.blocks?.adding(blockTransfer)
                }
            case .unknown:
                return
            }
            transfer.totalBlocks = Int64(transfer.transfers.count)
        }
        queueOperationsFor(blobTransfer: transfer)
    }

    // MARK: Cancel Operations

    public func cancel(transfer: Transfer) {
        transfer.state = .canceled
        assert(transfer.operation != nil, "Transfer operation unexpectedly nil.")
        if let operation = transfer.operation {
            operationQueue.remove(operation)
        }
        if let blob = transfer as? BlobTransfer {
            for block in blob.transfers {
                cancel(transfer: block)
            }
        }
        operation(transfer.operation, didChangeState: transfer.state)
    }

    // MARK: Remove Operations

    public func removeAll() {
        // Wipe the DataStore
        transfers.removeAll()

        // Clear the OperationQueue
        operationQueue.clear()

        // Delete all transfers in CoreData
        guard let context = persistentContainer?.viewContext else { return }
        let multiBlobRequest: NSFetchRequest<MultiBlobTransfer> = MultiBlobTransfer.fetchRequest()
        if let transfers = try? context.fetch(multiBlobRequest) {
            for transfer in transfers {
                context.delete(transfer)
            }
        }
        let blobRequest: NSFetchRequest<BlobTransfer> = BlobTransfer.fetchRequest()
        if let transfers = try? context.fetch(blobRequest) {
            for transfer in transfers {
                context.delete(transfer)
            }
        }
        let blockRequest: NSFetchRequest<BlockTransfer> = BlockTransfer.fetchRequest()
        if let transfers = try? context.fetch(blockRequest) {
            for transfer in transfers {
                context.delete(transfer)
            }
        }
        operations(nil, didChangeState: .deleted)
    }

    public func remove(transfer: Transfer) {
        switch transfer {
        case let transfer as BlockTransfer:
            remove(transfer: transfer)
        case let transfer as BlobTransfer:
            remove(transfer: transfer)
        default:
            fatalError("Unrecognized transfer type: \(transfer.self)")
        }
        transfer.state = .deleted
        operation(transfer.operation, didChangeState: .deleted)
    }

    internal func remove(transfer: BlockTransfer) {
        if let operation = transfer.operation {
            operationQueue.remove(operation)
        }

        if let index = transfers.firstIndex(where: { $0 === transfer }) {
            transfers.remove(at: index)
        }

        // remove the object from CoreData
        if let context = persistentContainer?.viewContext {
            context.delete(transfer)
        }
    }

    internal func remove(transfer: BlobTransfer) {
        // Cancel the operation and any associated block operations
        if let operation = transfer.operation {
            operationQueue.remove(operation)
            for block in transfer.transfers {
                block.state = .deleted
                if let blockOp = block.operation {
                    operationQueue.remove(blockOp)
                }
            }
        }

        // Remove the blob operation from the transfers list
        if let index = transfers.firstIndex(where: { $0 === transfer }) {
            transfers.remove(at: index)
        }

        // remove the object from CoreData which should cascade and delete any outstanding block transfers
        if let context = persistentContainer?.viewContext {
            context.delete(transfer)
        }
    }

    // MARK: Pause Operations

    public func pause(transfer: Transfer) {
        let allowed: [TransferState] = [.pending, .inProgress]
        guard allowed.contains(transfer.state) else { return }

        switch transfer {
        case let transfer as BlockTransfer:
            pause(transfer: transfer)
        case let transfer as BlobTransfer:
            pause(transfer: transfer)
        default:
            fatalError("Unrecognized transfer type: \(transfer.self)")
        }
        transfer.state = .paused
        operation(transfer.operation, didChangeState: transfer.state)
    }

    internal func pause(transfer: BlockTransfer) {
        assert(transfer.operation != nil, "Transfer operation unexpectedly nil.")
        if let operation = transfer.operation {
            operationQueue.pause(operation)
        }
    }

    internal func pause(transfer: BlobTransfer) {
        // Cancel the operation and any associated block operations
        if let operation = transfer.operation {
            operationQueue.remove(operation)
            // transfer.state = .paused
            for block in transfer.transfers {
                block.state = .paused
                if let blockOp = block.operation {
                    operationQueue.remove(blockOp)
                }
            }
        }
    }

    // MARK: Resume Operations

    public func resume(transfer: Transfer) {
        guard reachability?.isReachable ?? false else { return }
        let allowed: [TransferState] = [.paused]
        guard allowed.contains(transfer.state) else { return }
        transfer.state = .pending

        switch transfer {
        case let transfer as BlockTransfer:
            operationQueue.add(BlockOperation(withTransfer: transfer))
        case let transfer as BlobTransfer:
            for blockTransfer in transfer.transfers {
                if allowed.contains(blockTransfer.state) {
                    blockTransfer.state = .pending
                }
            }
            queueOperationsFor(blobTransfer: transfer)
        default:
            fatalError("Unrecognized transfer type: \(transfer.self)")
        }
        operation(transfer.operation, didChangeState: transfer.state)
    }

    // MARK: Core Data Operations

    public func loadContext() {
        // Hydrate operationQueue from CoreData
        guard let context = persistentContainer?.viewContext else {
            fatalError("Unable to load persistent container.")
        }
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        let predicate = NSPredicate(format: "parent = nil")
        let blockRequest: NSFetchRequest<BlockTransfer> = BlockTransfer.fetchRequest()
        blockRequest.predicate = predicate
        if let results = try? context.fetch(blockRequest) {
            for transfer in results {
                add(transfer: transfer)
            }
        }
        let blobRequest: NSFetchRequest<BlobTransfer> = BlobTransfer.fetchRequest()
        blobRequest.predicate = predicate
        if let results = try? context.fetch(blobRequest) {
            for transfer in results {
                add(transfer: transfer)
            }
        }
    }

    public func saveContext() {
        DispatchQueue.main.async { [weak self] in
            guard let context = self?.persistentContainer?.viewContext else { return }
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    let message = nserror.localizedDescription
                    fatalError("Unresolved error \(nserror.code): \(message)")
                }
            }
        }
    }
}
