//
//  AzureStorageBlobClient.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 9/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import Foundation

public class StorageBlobClient: PipelineClient, PagedCollectionDelegate {
    public enum ApiVersion: String {
        case latest = "2019-02-02"
    }

    private let apiVersion: ApiVersion!

    internal class StorageJSONDecoder: JSONDecoder {
        override init() {
            super.init()
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss zzzz"
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            dateDecodingStrategy = .formatted(formatter)
        }
    }

    internal class StorageJSONEncoder: JSONEncoder {
        override init() {
            super.init()
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss zzzz"
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            dateEncodingStrategy = .formatted(formatter)
        }
    }

    // MARK: Paged Collection Delegate

    public func continuationUrl(continuationToken: String, queryParams: inout [String: String],
                                requestUrl: String) -> String {
        queryParams["marker"] = continuationToken
        return requestUrl
    }

    // MARK: Initializers

    public init(accountName: String, connectionString: String, apiVersion: ApiVersion = .latest,
                logger: ClientLogger = ClientLoggers.default()) throws {
        let sasCredential = try StorageSASCredential(accountName: accountName, connectionString: connectionString)
        guard let blobEndpoint = sasCredential.blobEndpoint else {
            let message = "Invalid connection string. No blob endpoint specified."
            throw HttpResponseError.clientAuthentication(message)
        }
        let authPolicy = StorageSASAuthenticationPolicy(credential: sasCredential)
        self.apiVersion = apiVersion
        super.init(baseUrl: blobEndpoint,
                   transport: UrlSessionTransport(),
                   policies: [HeadersPolicy(), UserAgentPolicy(), authPolicy, ContentDecodePolicy(), LoggingPolicy()],
                   logger: logger)
    }

    // MARK: API Calls

    public func listContainers(withOptions options: ListContainersOptions? = nil,
                               completion: @escaping HttpResultHandler<PagedCollection<ContainerItem>>) {
        // Python: error_map = kwargs.pop('error_map', None)

        // Construct URL
        let urlTemplate = ""
        let url = format(urlTemplate: urlTemplate)

        // Construct query
        var queryParams = [String: String]()
        queryParams["comp"] = "list"

        // Construct headers
        var headerParams = HttpHeaders()
        headerParams[HttpHeader.accept] = "application/xml"
        headerParams[HttpHeader.apiVersion] = apiVersion.rawValue

        // Process endpoint options
        if let options = options {
            // Query options
            if let prefix = options.prefix { queryParams["prefix"] = prefix }
            if let include = options.include {
                queryParams["include"] = (include.map { $0.rawValue }).joined(separator: ",")
            }
            if let maxResults = options.maxResults { queryParams["maxresults"] = String(maxResults) }
            if let timeout = options.timeout { queryParams["timeout"] = String(timeout) }

            // Header options
            if let clientRequestId = options.clientRequestId {
                headerParams[HttpHeader.clientRequestId] = clientRequestId
            }
        }

        // Construct and send request
        let request = self.request(method: HttpMethod.GET,
                                   url: url,
                                   queryParams: queryParams,
                                   headerParams: headerParams)
        let codingKeys = PagedCodingKeys(
            items: "EnumerationResults.Containers",
            continuationToken: "EnumerationResults.NextMarker",
            xmlItemName: "Container"
        )
        let xmlMap = XMLMap(withPagedCodingKeys: codingKeys, innerType: ContainerItem.self)
        let context: [String: AnyObject] = [
            ContextKey.xmlMap.rawValue: xmlMap as AnyObject,
        ]
        run(request: request, context: context, completion: { result, httpResponse in
            switch result {
            case let .success(data):
                guard let data = data else {
                    let noDataError = HttpResponseError.decode("Response data expected but not found.")
                    completion(.failure(noDataError), httpResponse)
                    return
                }
                do {
                    let decoder = StorageJSONDecoder()
                    let paged = try PagedCollection<ContainerItem>(client: self, request: request, data: data,
                                                                   codingKeys: codingKeys, decoder: decoder,
                                                                   delegate: self)
                    completion(.success(paged), httpResponse)
                } catch {
                    completion(.failure(error), httpResponse)
                }
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        })
    }

    public func listBlobs(in container: String, withOptions options: ListBlobsOptions? = nil,
                          completion: @escaping HttpResultHandler<PagedCollection<BlobItem>>) {
        // Construct URL
        let urlTemplate = "{container}"
        let templateKwargs = [
            "container": container,
        ]
        let url = format(urlTemplate: urlTemplate, withKwargs: templateKwargs)

        // Construct query
        var queryParams = [String: String]()
        queryParams["comp"] = "list"
        queryParams["resType"] = "container"

        // Construct headers
        var headerParams = HttpHeaders()
        headerParams[HttpHeader.accept] = "application/xml"
        headerParams[HttpHeader.transferEncoding] = "chunked"
        headerParams[HttpHeader.apiVersion] = apiVersion.rawValue

        // Process endpoint options
        if let options = options {
            // Query options
            if let prefix = options.prefix { queryParams["prefix"] = prefix }
            if let delimiter = options.delimiter { queryParams["delimiter"] = delimiter }
            if let include = options.include {
                queryParams["include"] = (include.map { $0.rawValue }).joined(separator: ",")
            }
            if let maxResults = options.maxResults { queryParams["maxresults"] = String(maxResults) }
            if let timeout = options.timeout { queryParams["timeout"] = String(timeout) }

            // Header options
            if let clientRequestId = options.clientRequestId {
                headerParams[HttpHeader.clientRequestId] = clientRequestId
            }
        }

        // Construct and send request
        let request = self.request(method: HttpMethod.GET,
                                   url: url,
                                   queryParams: queryParams,
                                   headerParams: headerParams)
        let codingKeys = PagedCodingKeys(
            items: "EnumerationResults.Blobs",
            continuationToken: "EnumerationResults.NextMarker",
            xmlItemName: "Blob"
        )
        let xmlMap = XMLMap(withPagedCodingKeys: codingKeys, innerType: BlobItem.self)
        let context: [String: AnyObject] = [
            ContextKey.xmlMap.rawValue: xmlMap as AnyObject,
        ]
        run(request: request, context: context, completion: { result, httpResponse in
            switch result {
            case let .success(data):
                guard let data = data else {
                    let noDataError = HttpResponseError.decode("Response data expected but not found.")
                    completion(.failure(noDataError), httpResponse)
                    return
                }
                do {
                    let decoder = StorageJSONDecoder()
                    let paged = try PagedCollection<BlobItem>(client: self, request: request, data: data,
                                                              codingKeys: codingKeys, decoder: decoder, delegate: self)
                    completion(.success(paged), httpResponse)
                } catch {
                    completion(.failure(error), httpResponse)
                }
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        })
    }

    public func download(blob: String, fromContainer container: String,
                         completion: @escaping HttpResultHandler<Data>) {
        // Python: error_map = kwargs.pop('error_map', None)

        // Construct URL
        let urlTemplate = "/{container}/{blob}"
        let templateKwargs = [
            "container": container,
            "blob": blob,
        ]
        let url = format(urlTemplate: urlTemplate, withKwargs: templateKwargs)

        // Construct parameters
        var queryParams = [String: String]()

        // Construct headers
        var headerParams = HttpHeaders()
        headerParams[HttpHeader.apiVersion] = apiVersion.rawValue
        headerParams["x-ms-range"] = "bytes=0-33554431"
        // if let requestId = requestId { headerParams["x-ms-client-request-id"] = requestId }

        // Construct and send request
        let request = self.request(method: HttpMethod.GET,
                                   url: url,
                                   queryParams: queryParams,
                                   headerParams: headerParams)
        let context: [String: AnyObject] = [
            ContextKey.allowedStatusCodes.rawValue: [200, 206] as AnyObject,
        ]
        run(request: request, context: context, completion: { result, httpResponse in
            switch result {
            case let .success(data):
                guard let data = data else {
                    let noDataError = HttpResponseError.decode("Response data expected but not found.")
                    completion(.failure(noDataError), httpResponse)
                    return
                }
                completion(.success(data), httpResponse)
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        })
    }
}
