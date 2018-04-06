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

    
    static let dispatchQueue = DispatchQueue.global(qos: .default)
    
    
    static func cache<T:CodableResource>(_ resource: T) {
        
        if let paths = ResourceOracle.getFilePath(forResource: resource) {
            
            dispatchQueue.async {
                do {
                    let json = try jsonEncoder.encode(resource)
                    
                    try FileManager.default.cache(json, at: paths)
                    
                } catch {
                    log?.errorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    
    static func get<T:CodableResource>(resourceAt location: ResourceLocation) -> T? {
        
        do {
            if let paths = ResourceOracle.getFilePath(forResourceAt: location),
                let json = try FileManager.default.get(at: paths) {
            
                let resource = try jsonDecoder.decode(T.self, from: json)

                return resource
            }
        } catch {
            log?.errorMessage(error.localizedDescription)
            return nil
        }

        return nil
    }

    
    static func remove(resourceAt location: ResourceLocation) {
        
        do {
            if let paths = ResourceOracle.getFilePath(forResourceAt: location) {
                
                try FileManager.default.remove(at: paths)
            }
        } catch {
            log?.errorMessage(error.localizedDescription)
        }
    }
    
    
    public static func purge() {
        do {
            try FileManager.default.purge()
        } catch {
            log?.errorMessage(error.localizedDescription)
        }
    }
}


extension FileManager {
    
    fileprivate static let root = "com.azure.data"
    
    fileprivate func urls(for paths: (directory:String, resource:String)) throws -> (directory: URL, resource: URL) {
    
        do {
            let resource =  try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FileManager.root).appendingPathComponent(paths.resource)
            let directory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FileManager.root).appendingPathComponent(paths.directory)
            
            if !FileManager.default.fileExists(atPath: directory.path) {
                try self.createDirectory(at: directory, withIntermediateDirectories: true, attributes: /*[FileAttributeKey : Any]?*/nil)
            }
            
            return(directory, resource)
            
        } catch {
            throw error
        }
    }
    
    
    fileprivate func cache(_ resource: Data, at paths: (directory:String, resource:String)) throws {
        
        do {
            let urls = try self.urls(for: paths)
                
            try resource.write(to: urls.resource)
            
        } catch {
            throw error
        }
    }
    
    
    fileprivate func get(at paths: (directory:String, resource:String)) throws -> Data? {

        do {
            let urls = try self.urls(for: paths)
            
            return self.contents(atPath: urls.resource.path)
            
        } catch {
            throw error
        }
    }

    
    fileprivate func remove(at paths: (directory:String, resource:String)) throws {
        
        do {
            let urls = try self.urls(for: paths)
            
            try self.removeItem(at: urls.directory)
            
        } catch {
            throw error
        }
    }

    
    fileprivate func purge() throws {
        do {
            let root = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FileManager.root)
            
            try self.removeItem(at: root)
            
        } catch {
            throw error
        }
    }
}
