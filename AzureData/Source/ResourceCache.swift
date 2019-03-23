//
//  ResourceCache.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore


public class ResourceCache {

    // MARK: - Properties

    static var isEnabled = true

    static let jsonEncoder: JSONEncoder = {
        
        let encoder = JSONEncoder()
        
        encoder.dateEncodingStrategy = .custom(DocumentClient.roundTripIso8601Encoder)
        
        return encoder
    }()

    static let jsonDecoder: JSONDecoder = {
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom(DocumentClient.roundTripIso8601Decoder)
        
        return decoder
    }()

    static var dispatchQueue: DispatchQueue { return DispatchQueue.global(qos: .default) }

    // MARK: -

    static var resourceEncryptor: ResourceEncryptor? = nil

    // MARK: - cache

    private static func _cache<T:CodableResource>(_ resource: T) {
        
        guard isEnabled else { return }
        
        dispatchQueue.async {
            do {
                let json = try encrypt(jsonEncoder.encode(resource))

                try FileManager.default.cache(json, at: ResourceOracle.getFilePath(forResource: resource))
                
            } catch {
                Log.error("❌ Cache Error [_cache]: " + error.localizedDescription)
            }
        }
    }

    private static func _cache(_ data: Data, usingSelfLink selfLink: String) {
        guard isEnabled else { return }
        guard let resourceId = selfLink.path?.file else { return }

        dispatchQueue.async {
            do {
                try FileManager.default.cache(encrypt(data), at: (directory: selfLink, file: "\(selfLink)/\(resourceId).json"))
            } catch {
                Log.error("❌ Cache Error [_cache]: " + error.localizedDescription)
            }
        }
    }

    
    // consider passing in data and selflink here instead of encoding what we just decoded
    static func cache<T:CodableResource>(_ resource: T, replacing: Bool = false) {
        
        ResourceOracle.storeLinks(forResource: resource)
        
        _cache(resource)
    }

    static func cache(_ data: Data, usingSelfLink selfLink: String, andAltLink altLink: String, replacing: Bool = false) {
        if replacing {
            replace(data, usingSelfLink: selfLink, andAltLink: altLink)

            return
        }

        ResourceOracle.store(selfLink: selfLink, forAltLink: altLink)

        _cache(data, usingSelfLink: selfLink)
    }

    
    static func cache<T:CodableResources>(_ resources: T) {

        ResourceOracle.storeLinks(forResources: resources)
        
        for resource in resources.items {
            _cache(resource)
        }
    }

    static func cache<T: CodableResource>(_ resources: Resources<T>, for query: Query, usingContentPath contentPath: String) {
        guard resources.count > 0 else { return }

        ResourceOracle.storeLinks(forResources: resources)

        dispatchQueue.async {
            let metadata = ResourcesMetadata(resourceId: resources.resourceId, contentPath: contentPath)

            do {
                let metadataUrl = try FileManager.default.metadatafileUrl(for: query)
                try jsonEncoder.encode(metadata).write(to: metadataUrl)

                try resources.items.forEach { resource in
                    let data = try jsonEncoder.encode(resource)
                    let url = try FileManager.default.fileUrl(for: resource, asResultOf: query)

                    try data.write(to: url)
                }
            } catch {
                Log.error("❌ Cache Error \(#function): " + error.localizedDescription)
            }
        }
    }

    // MARK: - replace

    static func replace<T:CodableResource>(_ resource: T, at location: ResourceLocation) {
        
        remove(resourceAt: location)
        
        ResourceOracle.storeLinks(forResource: resource)
        
        _cache(resource)
    }

    static func replace(_ data: Data, usingSelfLink selfLink: String, andAltLink altLink: String) {
        remove(resourceWithSelfLink: selfLink)

        ResourceOracle.store(selfLink: selfLink, forAltLink: altLink)

        _cache(data, usingSelfLink: selfLink)
    }

    // MARK: - get

    static func get<T:CodableResource>(resourceAt location: ResourceLocation) -> T? {
        guard let data = get(resourceAt: location) else { return nil }

        do {
            var resource = try jsonDecoder.decode(T.self, from: data)
            resource.setAltLink(to: location.link)
            
            return resource

        } catch {
            Log.error("❌ Cache Error [get]: " + error.localizedDescription)

            return nil
        }
    }

    static func get(resourceAt location: ResourceLocation) -> Data? {

        guard isEnabled else { return nil }

        do {

            guard let data = try FileManager.default.file(at: ResourceOracle.getFilePath(forResourceAt: location)) else {
                return nil
            }

            return decrypt(data)

        } catch {
            Log.error("❌ Cache Error [get]: " + error.localizedDescription)

            return nil
        }
    }

    static func get<T:CodableResources>(resourcesAt location: ResourceLocation, withContinuation continuation: String? = nil, as type: T.Type = T.self) -> (resources: T?, continuation: String?)? {

        guard isEnabled else { return nil }
        
        guard location.isFeed else { return nil }
        
        do {
            let paginationParams = ResourcesPaginationParams(from: continuation)

            if let feed = ResourceOracle.getDirectoryPath(forResourceAt: location),
               let files = try FileManager.default.files(at: feed.path, paginateWith: paginationParams) {

                let items = try files.map { try jsonDecoder.decode(T.Item.self, from: decrypt($0)) }

                var resources = Resources(resourceId: feed.resourceId, count: items.count, items: items) as! T
                resources.setAltLinks(withContentPath: location.link)

                return (resources, paginationParams.next(in: files.count).stringValue)
            } else {
                return nil
            }
        } catch {
            Log.error("❌ Cache Error [get]: " + error.localizedDescription)
            return nil
        }
    }

    static func get<T: CodableResource>(for query: Query, as type: T.Type = T.self) -> Resources<T>? {
        guard isEnabled else { return nil }

        do {
            let metadataUrl = try FileManager.default.metadatafileUrl(for: query)

            if let metadata = FileManager.default.contents(atPath: metadataUrl.path) {
                let resourcesMetadata = try jsonDecoder.decode(ResourcesMetadata.self, from: metadata)

                let filesUrls = try FileManager.default.resultsFilesUrls(for: query)
                let data = filesUrls.compactMap { FileManager.default.contents(atPath: $0.path) }
                let items = try data.map { try jsonDecoder.decode(T.self, from: $0) }

                var resources = Resources(resourceId: resourcesMetadata.resourceId, count: items.count, items: items)
                resources.setAltLinks(withContentPath: resourcesMetadata.contentPath)

                return resources
            }

            return nil

        } catch {
            Log.error("❌ Cache Error \(#function): " + error.localizedDescription)
            return nil
        }
    }

    // MARK: - remove

    static func remove(resourceAt location: ResourceLocation) {
        
        guard isEnabled else {
            ResourceOracle.removeLink(forResourceAt: location)
            return
        }
        
        guard !location.isFeed else { return }
        
        do {
            try FileManager.default.remove(at: ResourceOracle.getDirectoryPath(forResourceAt: location)?.path)
                
            ResourceOracle.removeLink(forResourceAt: location)
            
        } catch {
            Log.error("❌ Cache Error [remove]: " + error.localizedDescription)
        }
    }

    static func remove(resourceWithSelfLink selfLink: String?) {
        guard let selfLink = selfLink else { return }
        guard isEnabled else { ResourceOracle.removeLinks(forResourceWithSelfLink: selfLink) ; return }

        do {
            try FileManager.default.remove(at: selfLink)

            ResourceOracle.removeLinks(forResourceWithSelfLink: selfLink)
        } catch {
            Log.error("❌ Cache Error [remove]: " + error.localizedDescription)
        }
    }

    // MARK: -

    public static func purge() throws {
        do {
            try FileManager.default.purge()
        } catch {
            Log.error("❌ Cache Error [purge]: " + error.localizedDescription)
            throw error
        }
    }

    private static func encrypt(_ data: Data) -> Data {
        guard let encryptor = resourceEncryptor else { return data }
        return encryptor.encrypt(data)
    }

    private static func decrypt(_ data: Data) -> Data {
        guard let encryptor = resourceEncryptor else { return data }
        return encryptor.decrypt(data)
    }
}

// MARK: - FileManager

extension FileManager {
    
    fileprivate static let root = "com.azure.data"

    func cacheFileUrl(for path: String) throws -> URL {
        
        return try self.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FileManager.root).appendingPathComponent(path)
    }

    
    fileprivate func fileUrl(for path: (directory:String, file:String)) throws -> URL {

        let directoryUrl = try cacheFileUrl(for: path.directory)

        // Create the directory for the resource if it does not exist.
        if !self.fileExists(atPath: directoryUrl.path) {
            try self.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        }

        // Create empty child directories for the resource if they don't exist.
        try path.directory.resourceType?
            .children
            .map { directoryUrl.appendingPathComponent($0.rawValue) }
            .filter { !fileExists(atPath: $0.path) }
            .forEach { try createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil) }

        return try cacheFileUrl(for: path.file)
    }

    fileprivate func fileUrl(for query: Query) throws -> URL {
        let url = try self.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(FileManager.root)
            .appendingPathComponent("queries")
            .appendingPathComponent("\(query.hashValue)")

        if !fileExists(atPath: url.path) {
            try self.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }

        return url
    }

    fileprivate func metadatafileUrl(for query: Query) throws -> URL {
        let url = try fileUrl(for: query)
            .appendingPathComponent("metadata.json")

        return url
    }

    fileprivate func resultsDirectoryUrl(for query: Query) throws -> URL {
        let url = try fileUrl(for: query)
            .appendingPathComponent("results")

        if !fileExists(atPath: url.path) {
            try self.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }

        return url
    }

    fileprivate func fileUrl(for resource: CodableResource, asResultOf query: Query) throws -> URL {
        let filename = "\(resource.selfLink?.lastPathComponent ?? resource.resourceId).json"
        let url = try resultsDirectoryUrl(for: query)
            .appendingPathComponent(filename)

        return url
    }

    fileprivate func resultsFilesUrls(for query: Query) throws -> [URL] {
        let url = try resultsDirectoryUrl(for: query)

        return try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    }

    fileprivate func fileUrls(for path: String) throws -> [URL] {
        
        let url = try cacheFileUrl(for: path)
        
        return try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).map { $0.appendingPathComponent($0.lastPathComponent).appendingPathExtension("json") }
    }

    
    fileprivate func cache(_ resource: Data, at path: (directory:String, file:String)?) throws {
        
        guard let path = path else { return }
        
        let url = try self.fileUrl(for: path)
        
        try resource.write(to: url)
    }
    
    
    fileprivate func file(at path: String?) throws -> Data? {

        guard let path = path else { return nil }
        
        let url = try self.cacheFileUrl(for: path)
        
        return self.contents(atPath: url.path)
    }

    
    fileprivate func files(at path: String?, paginateWith params: ResourcesPaginationParams) throws -> [Data]? {
        
        guard let path = path else { return nil }
        
        let urls = try self.fileUrls(for: path)
                           .sorted(by: { $0.absoluteString < $1.absoluteString })
                           .dropFirst(params.offset)
                           .prefix(params.limit)
        
        return urls.compactMap { self.contents(atPath: $0.path) }
    }
    
    fileprivate func remove(at path: String?) throws {
        
        guard let path = path else { return }
        
        let url = try self.cacheFileUrl(for: path)
        
        try self.removeItem(at: url)
    }

    
    fileprivate func purge() throws {

        let dbs = try self.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FileManager.root).appendingPathComponent("dbs")

        try purgeContents(of: dbs)
        
        let offers = try self.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FileManager.root).appendingPathComponent("offers")
        
        try purgeContents(of: offers)

        let queries = try self.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FileManager.root).appendingPathComponent("queries")

        try purgeContents(of: queries)
    }
    
    
    fileprivate func purgeContents(of url: URL) throws {
        
        if self.fileExists(atPath: url.path) {
            
            let contents = try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for item in contents {
                try self.removeItem(at: item)
            }
        }
    }
}

// MARK: - Continuation

fileprivate struct ResourcesPaginationParams: Codable {
    static let defaultLimit = 100

    enum CodingKeys: String, CodingKey {
        case offset
        case limit
    }

    let offset: Int
    let limit: Int
}


fileprivate extension ResourcesPaginationParams {
    init(from string: String?) {
        guard let string = string,
              let data = string.data(using: .utf8),
              let params = try? AzureData.jsonDecoder.decode(ResourcesPaginationParams.self, from: data) else {
                self.offset = 0
                self.limit = ResourcesPaginationParams.defaultLimit
                return
        }

        self.offset = params.offset
        self.limit = params.limit
    }

    init(maxItemCount: Int?) {
        self.offset = 0
        self.limit = maxItemCount ?? ResourcesPaginationParams.defaultLimit
    }

    func next(`in` count: Int) -> ResourcesPaginationParams? {
        let newOffset = offset + limit
        guard count > newOffset else { return nil }
        return ResourcesPaginationParams(offset: newOffset, limit: limit)
    }

    var stringValue: String? {
        guard let data = try? AzureData.jsonEncoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

fileprivate extension Optional where Wrapped == ResourcesPaginationParams {
    var stringValue: String? {
        guard let params = self else { return nil }
        return params.stringValue
    }
}

fileprivate struct ResourcesMetadata: Codable {
    let resourceId: String
    let contentPath: String
}
