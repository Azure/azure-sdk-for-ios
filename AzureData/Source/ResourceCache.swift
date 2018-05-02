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

    static func _cache<T:CodableResource>(_ resource: T) {
        
        guard isEnabled else { return }
        
        dispatchQueue.async {
            do {
                let json = try jsonEncoder.encode(resource)

                try FileManager.default.cache(json, at: ResourceOracle.getFilePath(forResource: resource))
                
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

    
    static func cache<T:CodableResource>(_ resources: Resources<T>) {
        
        ResourceOracle.storeLinks(forResources: resources)
        
        for resource in resources.items {
            _cache(resource)
        }
    }

    
    static func replace<T:CodableResource>(_ resource: T, at location: ResourceLocation) {
        
        remove(resourceAt: location)
        
        ResourceOracle.storeLinks(forResource: resource)
        
        _cache(resource)
    }
    
    
    static func get<T:CodableResource>(resourceAt location: ResourceLocation) -> T? {
        
        guard isEnabled else { return nil }
        
        do {
            if let file = try FileManager.default.file(at: ResourceOracle.getFilePath(forResourceAt: location)) {

                return try jsonDecoder.decode(T.self, from: file)
            }
        } catch {
            Log.error("❌ Cache Error [get]: " + error.localizedDescription)
            return nil
        }

        return nil
    }

    
    static func get<T:CodableResource>(resourcesAt location: ResourceLocation, as type: T.Type = T.self) -> Resources<T>? {
        
        guard isEnabled else { return nil }
        
        guard location.isFeed else { return nil }
        
        do {
            if let feed = ResourceOracle.getDirectoryPath(forResourceAt: location),
                let files = try FileManager.default.files(at: feed.path) {
               
                let resources = try files.map { try jsonDecoder.decode(type.self, from: $0) }
                
                return Resources<T>(resourceId: feed.resourceId, count: resources.count, items: resources)
            } else {
                return nil
            }
        } catch {
            Log.error("❌ Cache Error [get]: " + error.localizedDescription)
            return nil
        }
    }

    
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
    
    
    public static func purge() throws {
        do {
            try FileManager.default.purge()
        } catch {
            Log.error("❌ Cache Error [purge]: " + error.localizedDescription)
            throw error
        }
    }
}


extension FileManager {
    
    fileprivate static let root = "com.azure.data"

    fileprivate func fileUrl(for path: String) throws -> URL {
        
        return try self.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FileManager.root).appendingPathComponent(path)
    }

    
    fileprivate func fileUrl(for path: (directory:String, file:String)) throws -> URL {

        let directory = try fileUrl(for: path.directory)
        
        if !self.fileExists(atPath: directory.path) {
            try self.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        
        return try fileUrl(for: path.file)
    }

    
    fileprivate func fileUrls(for path: String) throws -> [URL] {
        
        let url = try fileUrl(for: path)
        
        return try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).map { $0.appendingPathComponent($0.lastPathComponent).appendingPathExtension("json") }
    }

    
    fileprivate func cache(_ resource: Data, at path: (directory:String, file:String)?) throws {
        
        guard let path = path else { return }
        
        let url = try self.fileUrl(for: path)
        
        try resource.write(to: url)
    }
    
    
    fileprivate func file(at path: String?) throws -> Data? {

        guard let path = path else { return nil }
        
        let url = try self.fileUrl(for: path)
        
        return self.contents(atPath: url.path)
    }

    
    fileprivate func files(at path: String?) throws -> [Data]? {
        
        guard let path = path else { return nil }
        
        let urls = try self.fileUrls(for: path)
        
        return urls.compactMap { self.contents(atPath: $0.path) }
    }

    
    fileprivate func remove(at path: String?) throws {
        
        guard let path = path else { return }
        
        let url = try self.fileUrl(for: path)
        
        try self.removeItem(at: url)
    }

    
    fileprivate func purge() throws {

        let dbs = try self.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FileManager.root).appendingPathComponent("dbs")

        try purgeContents(of: dbs)
        
        let offers = try self.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FileManager.root).appendingPathComponent("offers")
        
        try purgeContents(of: offers)
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
