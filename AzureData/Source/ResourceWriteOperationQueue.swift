//
//  ResourceWriteOperationQueue.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore

/// Handles the queue of resource write operations
/// waiting for an internet connection to be performed.
class ResourceWriteOperationQueue {

    static var shared = ResourceWriteOperationQueue()

    /// The list of pending write operations.
    private var writes = [ResourceWriteOperation]()

    /// The list of write operations performed online so far.
    private var processedWrites = [ResourceWriteOperation]()

    /// Whether the queue is currently performing the writes
    /// online or not.
    private var isSyncing = false

    private let dispatchQueue = DispatchQueue(label: "com.azure.data.WriteQueue", qos: .background, attributes: [], autoreleaseFrequency: .workItem, target: nil)

    private init() {
        load()
    }

    // MARK: - Public API

    /// Enqueues a 'create' or 'replace' operation to be performed
    /// online when the network becomes reachable.
    func addCreateOrReplace(resource: Data, location: ResourceLocation, httpHeaders: HttpHeaders? = nil, replacing: Bool = false, callback: @escaping (Response<Data>) -> ()) {
        createOrReplaceOffline(resource: resource, at: location, replacing: replacing) { [weak self] r in
            callback(r)

            if case .success = r.result {
                let type: ResourceWriteOperation.Kind = replacing ? .replace : .create
                self?.enqueue(ResourceWriteOperation(type: type, resource: resource, resourceLocation: location, resourceLocalContentPath: r.msContentPath!, httpHeaders: httpHeaders))
            }
        }
    }

    /// Enqueues a 'delete' operation to be performed online
    /// when the network becomes reachable.
    func addDelete(forResourceAt location: ResourceLocation, httpHeaders: HttpHeaders? = nil, callback: @escaping (Response<Data>) -> ()) {
        deleteOffline(resourceAt: location) { [weak self] r in
            callback(r)

            if case .success = r.result {
                self?.enqueue(ResourceWriteOperation(type: .delete, resource: nil, resourceLocation: location, resourceLocalContentPath: r.msContentPath!, httpHeaders: httpHeaders))
            }
        }
    }

    /// Performs all the pending write operations online.
    /// Posts a .OfflineResourceSyncSucceeded notification for each successful write
    /// and a .OfflineResourceSyncFailed notification for each write that fails.
    /// Posts a .ResourceWriteOperationQueueProcessed when the all the write
    /// operations have been successfully processed.
    func sync() {
        dispatchQueue.sync { [weak self] in
            guard let queue = self, !(queue.isSyncing || queue.writes.isEmpty) else { return }

            queue.isSyncing = true

            let writes = queue.writes.sortedByResourceType()

            queue.performWrites(writes) { isSuccess in
                if isSuccess {
                    NotificationCenter.default.post(name: .ResourceWriteOperationQueueProcessed, object: nil)
                }

                queue.removeCachedResources()

                queue.isSyncing = false
            }
        }
    }

    /// Purges the directory on the filesystem storing the pending writes.
    func purge() {
        dispatchQueue.sync { [weak self] in
            do {
                let urls = try FileManager.default.pendingWritesUrls()
                try urls.forEach { try FileManager.default.removeItem(at: $0) }
                self?.writes = []

            } catch {
                Log.error("❌ Write Queue Error [purge]: " + error.localizedDescription)
            }
        }
    }

    // MARK: - Private helpers

    private func load() {
        dispatchQueue.sync { [weak self] in
            do {
                let urls = try FileManager.default.pendingWritesUrls()
                let data = try urls.map { try Data(contentsOf: $0) }
                let decoder = JSONDecoder()

                self?.writes = data.compactMap { try? decoder.decode(ResourceWriteOperation.self, from: $0) }

            } catch {
                Log.error("❌ Write Queue Error [load]: " + error.localizedDescription)
            }
        }
    }

    private func performWrites(_ writes: [ResourceWriteOperation], completion: @escaping (Bool) -> ()) {
        var writes = writes

        guard !writes.isEmpty else { completion(true) ; return }

        let write = writes.removeFirst()

        performWrite(write) { [weak self] response in
            guard let queue = self else { completion(false) ; return }

            if !response.fromCache {
                queue.processedWrites.append(write)
                queue.postNotification(for: response)
                queue.removeWrite(write)
            }

            queue.performWrites(writes, completion: completion)
        }
    }

    private func performWrite(_ write: ResourceWriteOperation, callback: @escaping (Response<Data>) -> ()) {
        switch write.type {
        case .create, .replace:
            DocumentClient.shared.createOrReplace(write.resource!, at: write.resourceLocation, replacing: write.type == .replace, additionalHeaders: write.httpHeaders, callback: callback)
        case .delete:
            DocumentClient.shared.delete(resourceAt: write.resourceLocation, callback: callback)
        }
    }

    private func postNotification(for response: Response<Data>) {
        switch response.result {
        case .success(let data):
            NotificationCenter.default.post(name: .OfflineResourceSyncSucceeded, object: self, userInfo: ["data": data])
        case .failure(let error):
            NotificationCenter.default.post(name: .OfflineResourceSyncFailed, object: self, userInfo: ["error": error])
        }
    }

    private func removeCachedResources() {
        while !processedWrites.isEmpty {
            let path = processedWrites.removeLast().resourceLocalContentPath
            removeResourceCached(at: path)
        }
    }

    private func removeResourceCached(at path: String?) {
        guard let path = path else { return }

        do {
            try FileManager.default.removeItem(at: FileManager.default.cacheFileUrl(for: path))
        } catch {
            Log.error("❌ Write Queue Error [removeResourceCached]: " + error.localizedDescription)
        }
    }

    private func removeWrite(_ write: ResourceWriteOperation) {
        if let index = writes.firstIndex(of: write) {
            writes.remove(at: index)
        }

        removeWriteFromDisk(write)
    }

    private func enqueue(_ write: ResourceWriteOperation) {
        dispatchQueue.sync {
            guard let index = writes.firstIndex(of: write) else {
                writes.append(write)
                persistWriteOnDisk(write)
                return
            }

            let existingWrite = writes[index]

            switch (existingWrite.type, write.type) {
            // If we try to replace a resource previously created,
            // we should instead create the resource with the new
            // parameters.
            case (.create, .replace):
                writes[index] = write.withType(.create)
                removeWriteFromDisk(existingWrite)
                persistWriteOnDisk(write.withType(.create))

            // If we try to delete a previously created resource,
            // we remove the create operation from the queue
            // so that nothing is done once we come online.
            case (.create, .delete):
                writes.remove(at: index)
                removeWriteFromDisk(existingWrite)

            // If we try to delete a resource that was previously
            // updated, we subtitute the replace operation
            // with the delete one.
            case (.replace, .delete):
                writes[index] = write
                removeWriteFromDisk(existingWrite)
                persistWriteOnDisk(write)

            // If we try to update a previously updated resource
            // we replace the old replace operation with the new one.
            case (.replace, .replace):
                writes[index] = write
                removeWriteFromDisk(existingWrite)
                persistWriteOnDisk(write)

            // If we try to delete a previously delete resource,
            // we just keep the previous delete in the queue.
            case (.delete, .delete):
                break

            // The following cases are conflicts and should
            // ideally not happen.
            case (.create, .create),
                 (.replace, .create),
                 (.delete, .create),
                 (.delete, .replace):
                break
            }
        }
    }

    private func persistWriteOnDisk(_ write: ResourceWriteOperation) {
        do {
            try FileManager.default.persistWrite(write)

        } catch {
            Log.error("❌ Write Queue Error [persistWriteOnDisk]: " + error.localizedDescription)
        }
    }

    private func removeWriteFromDisk(_ write: ResourceWriteOperation) {
        do {
            try FileManager.default.removeWrite(write)

        } catch {
            Log.error("❌ Write Queue Error [removeWriteFromDisk]: " + error.localizedDescription)
        }
    }

    private func createOrReplaceOffline(resource: Data, at location: ResourceLocation, replacing: Bool = false, callback: @escaping  (Response<Data>) -> ()) {
        guard let id = resource.id, id.isValidIdForResource else {
            callback(Response(DocumentClientError(withKind: .invalidId), fromCache: true))
            return
        }

        let altLink = location.altLink(forId: id)
        let knownSelfLink = ResourceOracle.getSelfLink(forAltLink: altLink)

        if replacing && knownSelfLink.isNilOrEmpty {
            callback(Response(DocumentClientError(withKind: .notFound), fromCache: true))
            return
        }

        if !replacing && !knownSelfLink.isNilOrEmpty {
            callback(Response(DocumentClientError(withKind: .conflict), fromCache: true))
            return
        }

        guard let selfLink = knownSelfLink ?? location.selfLink(forResourceId: UUID().uuidString) else {
            callback(Response(DocumentClientError(withKind: .internalError), fromCache: true))
            return
        }

        ResourceCache.cache(resource, usingSelfLink: selfLink, andAltLink: altLink, replacing: replacing)

        let httpResponse = HTTPURLResponse(url: URL(string: selfLink)!, statusCode: replacing ? 200 : 201, httpVersion: nil, headerFields: [
                MSHttpHeader.msAltContentPath.rawValue: altLink.ancestorPath.valueOrEmpty,
                MSHttpHeader.msContentPath.rawValue: selfLink
            ]
        )!

        callback(Response(request: nil, data: nil, response: httpResponse, result: .success(resource), fromCache: true))
    }

    private func deleteOffline(resourceAt location: ResourceLocation, callback: @escaping (Response<Data>) -> ()) {
        guard let selfLink = ResourceOracle.getSelfLink(forAltLink: location.link) else {
            callback(Response(DocumentClientError(withKind: .notFound), fromCache: true))
            return
        }

        ResourceCache.remove(resourceAt: location)

        let httpResponse = HTTPURLResponse(url: URL(string: selfLink)!, statusCode: 204, httpVersion: nil, headerFields: [
                MSHttpHeader.msAltContentPath.rawValue: location.link.ancestorPath.valueOrEmpty,
                MSHttpHeader.msContentPath.rawValue: selfLink
            ]
        )!

        callback(Response(request: nil, data: nil, response: httpResponse, result: .success(Data()), fromCache: true))
    }
}

// MARK: - Notifications

extension Notification.Name {
    public static let OfflineResourceSyncSucceeded         = Notification.Name("OfflineResourceSyncSucceeded")
    public static let OfflineResourceSyncFailed            = Notification.Name("OfflineResourceSyncFailed")
    public static let ResourceWriteOperationQueueProcessed = Notification.Name("OfflineResourceQueueProcessed")
}

// MARK: - FileManager

extension FileManager {
    fileprivate static let root = "com.azure.data/writes"

    fileprivate func pendingWritesUrls() throws -> [URL] {
        let rootUrl = try url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(FileManager.root)

        if fileExists(atPath: rootUrl.path) {
            let contents = try contentsOfDirectory(at: rootUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return contents
        }

        return []
    }

    fileprivate func persistWrite(_ write: ResourceWriteOperation) throws {
        guard let data = try? JSONEncoder().encode(write) else { return }

        let rootUrl = try url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(FileManager.root)

        if !fileExists(atPath: rootUrl.path) {
            try createDirectory(at: rootUrl, withIntermediateDirectories: true)
        }

        try data.write(to: rootUrl.appendingPathComponent("\(write.hashValue).json"))
    }

    fileprivate func removeWrite(_ write: ResourceWriteOperation) throws {
        let writeUrl = try url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(FileManager.root)
            .appendingPathComponent("\(write.hashValue).json")

        if FileManager.default.fileExists(atPath: writeUrl.path) {
            try FileManager.default.removeItem(at: writeUrl)
        }
    }
}
