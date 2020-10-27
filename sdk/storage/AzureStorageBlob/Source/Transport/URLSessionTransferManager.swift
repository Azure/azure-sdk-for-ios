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

// swiftlint:disable:next type_body_length
internal final class URLSessionTransferManager: NSObject, TransferManager, URLSessionTaskDelegate {
    // MARK: Type Alias

    public typealias TransferManagerType = URLSessionTransferManager

    // MARK: Properties

    var clients = NSMapTable<NSString, StorageBlobClient>.strongToWeakObjects()

    lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.azuresdk.transfermanager")
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    var reachability: ReachabilityManager?

    internal var networkStatus: NetworkState = .unknown

    lazy var operationQueue: TransferOperationQueue = {
        let operationQueue = TransferOperationQueue()
        operationQueue.maxConcurrentOperationCount = StorageBlobClient.maxConcurrentTransfersDefaultValue
        return operationQueue
    }()

    var maxConcurrency: Int {
        get { return operationQueue.maxConcurrentOperationCount }
        set { operationQueue.maxConcurrentOperationCount = newValue }
    }

    var transfers: [TransferImpl]

    var count: Int {
        return transfers.count
    }

    var persistentContainer: NSPersistentContainer {
        return URLSessionTransferManager.sharedPersistentContainer
    }

    static var sharedPersistentContainer: NSPersistentContainer = {
        guard let bundle = Bundle(identifier: "com.azure.storage.AzureStorageBlob"),
            let url = bundle.url(forResource: "AzureStorage", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url)
        else {
            fatalError("Unable to load AzureStorageBlob managed object model.")
        }
        let container = NSPersistentContainer(name: "AzureSDKTransferManager", managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true

        return container
    }()

    /// Retrieve all managed transfers created by the transfer manager.
    internal var transferCollection: TransferCollection {
        let matching = transfers.compactMap { $0 as? BlobTransfer }
        return TransferCollection(matching)
    }

    /// Retrieve all managed downloads created by the transfer manager.
    internal var downloadCollection: TransferCollection {
        let matching: [BlobTransfer] = transfers.compactMap { transfer in
            guard let transfer = transfer as? BlobTransfer else { return nil }
            return transfer.transferType == .download ? transfer : nil
        }
        return TransferCollection(matching)
    }

    /// Retrieve all managed uploads created by the transfer manager.
    internal var uploadCollection: TransferCollection {
        let matching: [BlobTransfer] = transfers.compactMap { transfer in
            guard let transfer = transfer as? BlobTransfer else { return nil }
            return transfer.transferType == .upload ? transfer : nil
        }
        return TransferCollection(matching)
    }

    // MARK: Initializers

    override private init() {
        self.transfers = [TransferImpl]()
        super.init()
        self.reachability = ReachabilityManager()
        reachability?.registerListener { status in
            switch status {
            case .notReachable:
                self.networkStatus = .disconnected
                // No reason not to automatically pause--the alternative is everything failing
                self.pauseAll()
            case .reachable(.ethernetOrWiFi):
                self.networkStatus = .wifiOrEthernet
                self.handleNetworkTransition()
            case .reachable(.wwan):
                self.networkStatus = .cellular
                self.handleNetworkTransition()
            default:
                self.networkStatus = .unknown
            }
        }
        reachability?.startListening()
    }

    public static var shared: URLSessionTransferManager = {
        let manager = URLSessionTransferManager()
        manager.loadContext()
        return manager
    }()

    // MARK: TransferManager Methods

    subscript(index: Int) -> TransferImpl {
        // return the operation from the DataStore
        return transfers[index]
    }

    func register(client: StorageBlobClient) throws {
        let restorationId = client.options.restorationId
        guard blobClient(forRestorationId: restorationId) == nil else {
            throw AzureError.client(
                """
                    A client with restoration ID \(restorationId) already exists. Please ensure that each client has a \
                    unique restoration ID.
                """
            )
        }
        clients.setObject(client, forKey: restorationId as NSString)
    }

    func client(forRestorationId restorationId: String) -> PipelineClient? {
        return clients.object(forKey: restorationId as NSString)
    }

    func blobClient(forRestorationId restorationId: String) -> StorageBlobClient? {
        return client(forRestorationId: restorationId) as? StorageBlobClient
    }

    // MARK: Add Operations

    func add(transfer: TransferImpl) {
        switch transfer {
        case let transfer as BlockTransfer:
            add(transfer: transfer)
        case let transfer as BlobTransfer:
            add(transfer: transfer)
        default:
            fatalError("Unexpected operation type: \(transfer.self)")
        }
    }

    func add(transfer: BlockTransfer) {
        // Add to DataStore
        transfers.append(transfer)

        // Add to OperationQueue and notify delegate
        let operation = BlockOperation(withTransfer: transfer, delegate: self)
        operationQueue.add(operation)
        self.transfer(transfer, didUpdateWithState: transfer.state, andProgress: transfer.parent.progress)
    }

    func queueOperations(for transfer: BlobTransfer) {
        guard transfer.isActive else { return }
        var operations = [TransferOperation]()
        var pendingTransfers: [Transfer]
        switch transfer.transferType {
        case .download:
            pendingTransfers = transfer.transfers.filter { $0.isActive }
            if transfer.initialCallComplete {
                let finalOperation = BlobDownloadFinalOperation(
                    withTransfer: transfer,
                    queue: operationQueue,
                    delegate: self
                )
                operations.append(finalOperation)
                for transfer in pendingTransfers {
                    guard let blockTransfer = transfer as? BlockTransfer else { continue }
                    let blockOperation = BlockOperation(withTransfer: blockTransfer, delegate: self)
                    finalOperation.addDependency(blockOperation)
                    operations.append(blockOperation)
                }
            } else {
                guard let initialTransfer = pendingTransfers.first as? BlockTransfer else {
                    assertionFailure("Invalid assumption regarding pending transfers.")
                    return
                }
                let initialOperation = BlobDownloadInitialOperation(
                    withTransfer: initialTransfer,
                    queue: operationQueue,
                    delegate: self
                )
                operations.append(initialOperation)
            }
        case .upload:
            let finalOperation = BlobUploadFinalOperation(withTransfer: transfer, queue: operationQueue, delegate: self)
            operations.append(finalOperation)
            pendingTransfers = transfer.transfers.filter { $0.isActive }
            for transfer in pendingTransfers {
                guard let blockTransfer = transfer as? BlockTransfer else { continue }
                let blockOperation = BlockOperation(withTransfer: blockTransfer, delegate: self)
                finalOperation.addDependency(blockOperation)
                operations.append(blockOperation)
            }
        }
        operationQueue.add(operations)
        transfersDidUpdate(pendingTransfers)
    }

    func add(transfer: BlobTransfer) {
        guard let context = transfer.managedObjectContext else { return }

        // Add to DataStore
        transfers.append(transfer)

        if transfer.transfers.isEmpty, transfer.state == .pending {
            switch transfer.transferType {
            case .download:
                let blockTransfer = BlockTransfer.with(
                    context: context,
                    startRange: 0,
                    endRange: 1,
                    parent: transfer
                )
                transfer.blocks?.adding(blockTransfer)
            case .upload:
                guard let uploader = transfer.uploader else { return }
                for (range, blockId) in uploader.blockList {
                    let blockTransfer = BlockTransfer
                        .with(
                            context: context,
                            id: blockId,
                            startRange: Int64(range.startIndex),
                            endRange: Int64(range.endIndex),
                            parent: transfer
                        )
                    transfer.blocks?.adding(blockTransfer)
                }
            }
            transfer.totalBlocks = Int64(transfer.transfers.count)
        }

        func shouldAllow(transfer: Transfer) -> Bool {
            guard let blobTransfer = transfer as? BlobTransfer else { return true }
            guard let blobClient = client(forRestorationId: blobTransfer.clientRestorationId) as? StorageBlobClient
            else { return true }
            guard let status = networkStatus.publicValue else { return false }

            switch blobTransfer.transferType {
            case .download:
                return blobClient.options.downloadNetworkPolicy.shouldTransfer(withStatus: status)
            case .upload:
                return blobClient.options.uploadNetworkPolicy.shouldTransfer(withStatus: status)
            }
        }

        // if transfer should not occur on specific network type, it should immediately pause
        if !shouldAllow(transfer: transfer) {
            transfer.pause()
            return
        }
        queueOperations(for: transfer)
    }

    // MARK: Cancel Operations

    func cancel(transfer: TransferImpl) {
        transfer.state = .canceled
        assert(transfer.operation != nil, "Transfer operation unexpectedly nil.")
        if let operation = transfer.operation {
            operation.cancel()
        }
        if let blob = transfer as? BlobTransfer {
            for block in blob.transfers {
                cancel(transfer: block)
            }
        }
        self.transfer(transfer, didUpdateWithState: transfer.state, andProgress: nil)
    }

    // MARK: Remove Operations

    func removeAll() {
        // Wipe the DataStore
        transfers.removeAll()

        // Clear the OperationQueue
        operationQueue.cancelAllOperations()

        // Delete all transfers in CoreData
        let context = persistentContainer.viewContext
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
    }

    func remove(transfer: TransferImpl) {
        switch transfer {
        case let transfer as BlockTransfer:
            remove(transfer: transfer)
        case let transfer as BlobTransfer:
            remove(transfer: transfer)
        default:
            fatalError("Unrecognized transfer type: \(transfer.self)")
        }
        transfer.state = .deleted
        self.transfer(transfer, didUpdateWithState: transfer.state, andProgress: nil)
    }

    func remove(transfer: BlockTransfer) {
        if let operation = transfer.operation {
            operation.cancel()
        }

        if let index = transfers.firstIndex(where: { $0 === transfer }) {
            transfers.remove(at: index)
        }

        // remove the object from CoreData
        if let context = transfer.managedObjectContext {
            context.delete(transfer)
        }
    }

    internal func remove(transfer: BlobTransfer) {
        // Cancel the operation and any associated block operations
        if let operation = transfer.operation {
            operation.cancel()
            for block in transfer.transfers {
                block.state = .deleted
                if let blockOp = block.operation {
                    blockOp.cancel()
                }
            }
        }

        // Remove the blob operation from the transfers list
        if let index = transfers.firstIndex(where: { $0 === transfer }) {
            transfers.remove(at: index)
        }

        // remove the object from CoreData which should cascade and delete any outstanding block transfers
        if let context = transfer.managedObjectContext {
            context.delete(transfer)
        }
    }

    // MARK: Pause Operations

    func pauseAll() {
        operationQueue.cancelAllOperations()
        for transfer in transfers {
            pause(transfer: transfer)
        }
    }

    func pause(transfer: TransferImpl) {
        guard let blobTransfer = transfer as? BlobTransfer else {
            assertionFailure("Unsupported transfer type: \(transfer.self)")
            return
        }
        pause(transfer: blobTransfer)
    }

    func pause(transfer: BlobTransfer) {
        guard transfer.state.active else { return }
        transfer.state = .paused

        // Cancel the operation
        if let operation = transfer.operation {
            operation.cancel()
        }

        // Pause any pauseable blocks and cancel their operations
        for block in transfer.transfers {
            pause(transfer: block)
        }

        // notify delegate
        self.transfer(transfer, didUpdateWithState: transfer.state, andProgress: transfer.progress)
    }

    func pause(transfer: BlockTransfer) {
        guard transfer.state.active else { return }
        transfer.state = .paused

        // Cancel the operation
        if let operation = transfer.operation {
            operation.cancel()
        }

        // notify delegate
        self.transfer(transfer, didUpdateWithState: transfer.state, andProgress: transfer.parent.progress)
    }

    // MARK: Resume Operations

    func shouldAllow(transfer: Transfer) -> Bool {
        guard let blobTransfer = transfer as? BlobTransfer else { return true }
        let blobClient = client(forRestorationId: transfer.clientRestorationId) as? StorageBlobClient
        guard let status = networkStatus.publicValue else {
            return false
        }
        switch blobTransfer.transferType {
        case .download:
            return blobClient?.options.downloadNetworkPolicy.shouldTransfer(withStatus: status) ?? true
        case .upload:
            return blobClient?.options.uploadNetworkPolicy.shouldTransfer(withStatus: status) ?? true
        }
    }

    func resumeAll(withRestorationId restorationId: String? = nil, progressHandler: ((BlobTransfer) -> Void)? = nil) {
        let toResume = restorationId == nil ? transfers : transfers.filter { $0.clientRestorationId == restorationId }
        for transfer in toResume {
            resume(transfer: transfer, progressHandler: progressHandler)
        }
    }

    func resume(transfer: TransferImpl, progressHandler: ((BlobTransfer) -> Void)? = nil) {
        // reconnect blobTransfer with progress handler, regardless of network status.
        // do not overwrite progress handler if it already is attached
        if let blobTransfer = transfer as? BlobTransfer {
            blobTransfer.progressHandler = progressHandler ?? blobTransfer.progressHandler
        }

        guard transfer.state.resumable else { return }
        guard shouldAllow(transfer: transfer) else { return }

        transfer.state = .pending
        switch transfer {
        case let transfer as BlockTransfer:
            operationQueue.add(BlockOperation(withTransfer: transfer, delegate: self))
        case let transfer as BlobTransfer:
            for blockTransfer in transfer.transfers where blockTransfer.state.resumable {
                blockTransfer.state = .pending
            }
            reconnectClient(for: transfer)
            if transfer.state == .failed {
                self.transfer(transfer, didUpdateWithState: transfer.state, andProgress: nil)
            }
            queueOperations(for: transfer)
        default:
            assertionFailure("Unrecognized transfer type: \(transfer.self)")
        }
        self.transfer(transfer, didUpdateWithState: transfer.state, andProgress: nil)
    }

    // MARK: Misc Methods

    func handleNetworkTransition() {
        let clientEnumerator = clients.objectEnumerator()
        while let client: StorageBlobClient = clientEnumerator?.nextObject() as? StorageBlobClient {
            guard let status = networkStatus.publicValue else {
                client.transfers.pauseAll()
                continue
            }
            let downloadPolicy = client.options.downloadNetworkPolicy
            if downloadPolicy.shouldTransfer(withStatus: status) {
                if downloadPolicy.autoResumeOn.contains(status) {
                    client.downloads.resumeAll()
                }
            } else {
                client.downloads.pauseAll()
            }
            let uploadPolicy = client.options.uploadNetworkPolicy
            if uploadPolicy.shouldTransfer(withStatus: status) {
                if uploadPolicy.autoResumeOn.contains(status) {
                    client.uploads.resumeAll()
                }
            } else {
                client.uploads.pauseAll()
            }
        }
    }

    func reconnectClient(for transfer: BlobTransfer) {
        // early out if a client is already connected
        switch transfer.transferType {
        case .upload:
            guard transfer.uploader == nil else { return }
        case .download:
            guard transfer.downloader == nil else { return }
        }

        // attempt to attach one
        guard let client = blobClient(forRestorationId: transfer.clientRestorationId) else {
            let errorMessage = """
                Attempted to resume this transfer, but no client with restorationId "\(transfer.clientRestorationId)" \
                has been initialized.
            """
            assertionFailure(errorMessage)
            transfer.error = AzureError.client(errorMessage)
            transfer.state = .failed
            return
        }
        do {
            switch transfer.transferType {
            case .upload:
                guard let sourceUrl = transfer.source else { return }
                guard let destUrl = transfer.destination else { return }
                let source = LocalURL(fromAbsoluteUrl: sourceUrl)
                let blobProperties = transfer.properties
                let uploadOptions = transfer.uploadOptions
                transfer.uploader = try BlobStreamUploader(
                    client: client,
                    delegate: nil,
                    source: source,
                    destination: destUrl,
                    properties: blobProperties,
                    options: uploadOptions
                )
                transfer.uploader?.progress = Int(transfer.bytesTransferred)
            case .download:
                guard let sourceUrl = transfer.source else { return }
                guard let destUrl = transfer.destination else { return }
                let destination = LocalURL(fromAbsoluteUrl: destUrl)
                transfer.downloader = try BlobStreamDownloader(
                    client: client,
                    delegate: nil,
                    source: sourceUrl,
                    destination: destination,
                    options: transfer.downloadOptions
                )
                transfer.downloader?.progress = Int(transfer.bytesTransferred)
                transfer.downloader?.totalSize = Int(transfer.totalBytesToTransfer)
            }
        } catch {
            client.logger.error(error.localizedDescription)
            transfer.error = error
            transfer.state = .failed
            return
        }
    }

    // MARK: Core Data Operations

    func loadContext() {
        // Hydrate operationQueue from CoreData
        let context = persistentContainer.viewContext

        // All BlockTransfers must have a parent, so this is an error condition
        let predicate = NSPredicate(format: "parent = nil")
        let blockRequest: NSFetchRequest<BlockTransfer> = BlockTransfer.fetchRequest()
        blockRequest.predicate = predicate
        if let results = try? context.fetch(blockRequest) {
            assert(results.count == 0, "Unexpectedly found \(results.count) orphan BlockTransfers.")
        }

        let blobRequest: NSFetchRequest<BlobTransfer> = BlobTransfer.fetchRequest()
        blobRequest.predicate = predicate
        if let results = try? context.fetch(blobRequest) {
            for transfer in results {
                transfers.append(transfer)
            }
        }
    }

    func save(context: NSManagedObjectContext) {
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    let message = nserror.localizedDescription
                    let errorMessage = "Unresolved error \(nserror.code): \(message)"
                    assertionFailure(errorMessage)
                }
            }
        }
    }
}
