//
//  DefaultPermissionProvider.swift
//  AzureMobile
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore
import AzureData

public struct PermissionRequest : Codable {
    
    let databaseId: String
    let collectionId: String
    let documentId: String?
    let resourceLink: String?
    let tokenDuration: Int
    let permissionMode: PermissionMode
}

public class DefaultPermissionProvider : PermissionProvider {

    let baseUrl: URL
    
    let session: URLSession


    lazy var encoder: JSONEncoder = getPermissionEncoder()
    
    lazy var decoder: JSONDecoder = getPermissionDecoder()


    public var configuration: PermissionProviderConfiguration!
    
    
    public init (withBaseUrl url: URL, providerConfiguration: PermissionProviderConfiguration = PermissionProviderConfiguration.default, sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        baseUrl = url
        configuration = providerConfiguration
        session = URLSession(configuration: sessionConfiguration)
    }

    
    public func getPermission(forCollectionWithId collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        let permissionRequest = PermissionRequest(databaseId: databaseId, collectionId: collectionId, documentId: nil, resourceLink: nil, tokenDuration: Int(configuration.defaultTokenDuration), permissionMode: mode)
        getPermission(with: permissionRequest, completion: completion)
    }

    public func getPermission(forDocumentWithId documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        let altLink = "\(ResourceType.database.rawValue)/\(databaseId)/\(ResourceType.collection.rawValue)/\(collectionId)/\(ResourceType.document.rawValue)/\(documentId)"
        getPermission(forResourceWithAltLink: altLink, inDocument: documentId, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
    }

    public func getPermission(forAttachmentsWithId attachmentId: String, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        let altLink = "\(ResourceType.database.rawValue)/\(databaseId)/\(ResourceType.collection.rawValue)/\(collectionId)/\(ResourceType.document.rawValue)/\(documentId)/\(ResourceType.attachment.rawValue)/\(attachmentId)"
        getPermission(forResourceWithAltLink: altLink, inDocument: documentId, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)

    }

    public func getPermission(forStoredProcedureWithId storedProcedureId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        let altLink = "\(ResourceType.database.rawValue)/\(databaseId)/\(ResourceType.collection.rawValue)/\(collectionId)/\(ResourceType.storedProcedure.rawValue)/\(storedProcedureId)"
        getPermission(forResourceWithAltLink: altLink, inDocument: nil, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
    }

    public func getPermission(forUserDefinedFunctionWithId functionId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        let altLink = "\(ResourceType.database.rawValue)/\(databaseId)/\(ResourceType.collection.rawValue)/\(collectionId)/\(ResourceType.udf.rawValue)/\(functionId)"
        getPermission(forResourceWithAltLink: altLink, inDocument: nil, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
    }

    public func getPermission(forTriggerWithId triggerId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        let altLink = "\(ResourceType.database.rawValue)/\(databaseId)/\(ResourceType.collection.rawValue)/\(collectionId)/\(ResourceType.trigger.rawValue)/\(triggerId)"
        getPermission(forResourceWithAltLink: altLink, inDocument: nil, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
    }

    private func getPermission(forResourceWithAltLink altLink: String, inDocument documentId: String?, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        guard let resourceLink = ResourceOracle.getSelfLink(forAltLink: altLink) else {
            completion(Response(PermissionProviderError.getPermissionFailed))
            return
        }

        let permissionRequest = PermissionRequest(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            resourceLink: resourceLink,
            tokenDuration: Int(configuration.defaultTokenDuration),
            permissionMode: mode
        )

        getPermission(with: permissionRequest, completion: completion)
    }

    private func getPermission(with permissionRequest: PermissionRequest, completion: @escaping (Response<Permission>) -> Void) {
        let url = baseUrl.appendingPathComponent("api/data/permission")

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try encoder.encode(permissionRequest)
        } catch {
            completion(Response(PermissionProviderError.getPermissionFailed)); return;
        }

        session.dataTask(with: request) { (data, response, error) in

            let httpResponse = response as? HTTPURLResponse

            if let error = error {

                completion(Response(request: request, data: data, response: httpResponse, result: .failure(error)))

            } else if let data = data {

                //Log.debugMessage(String(data: data, encoding: .utf8) ?? "fail")

                do {
                    let permission = try self.decoder.decode(Permission.self, from: data)

                    completion(Response(request: request, data: data, response: httpResponse, result: .success(permission)))

                } catch {

                    completion(Response(request: request, data: data, response: httpResponse, result: .failure(error))); return;
                }
            } else {

                completion(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withKind: .unknownError)))); return;
            }
        }.resume()
    }
}
