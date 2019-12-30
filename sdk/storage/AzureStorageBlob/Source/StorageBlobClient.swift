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
import Foundation

/**
 Client object for the Storage blob service.
 */
public class StorageBlobClient: PipelineClient, PagedCollectionDelegate {

    /// API version of the service to invoke. Defaults to the latest.
    public enum ApiVersion: String {
        case latest = "2019-02-02"
    }

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

    private let credential: Any

    public var options: StorageBlobClientOptions

    private let defaultScopes = [
        "https://storage.azure.com/.default"
    ]

    // MARK: Paged Collection Delegate

    public func continuationUrl(continuationToken: String, queryParams: inout [String: String],
                                requestUrl: String) -> String {
        queryParams["marker"] = continuationToken
        return requestUrl
    }

    // MARK: Initializers

    /**
     Create a Storage blob data client.
     - Parameter accountUrl: Base URL for the storage account.
     - Parameter credential: A credential object used to retrieve authentication tokens.
     - Parameter withOptions: A `StorageBlobClientOptions` object to control the download.
     - Returns: A `StorageBlobClient` object.
     */
    required public init(accountUrl: String, credential: Any, withOptions options: StorageBlobClientOptions? = nil)
        throws {
            self.credential = credential
            self.options = options ?? StorageBlobClientOptions(apiVersion: ApiVersion.latest.rawValue)
            let authPolicy: AuthenticationProtocol
            var baseUrl: String
            if let sasCredential = credential as? StorageSASCredential {
                guard let blobEndpoint = sasCredential.blobEndpoint else {
                    let message = "Invalid connection string. No blob endpoint specified."
                    throw AzureError.general(message)
                }
                baseUrl = blobEndpoint
                authPolicy = StorageSASAuthenticationPolicy(credential: sasCredential)
            } else if let oauthCredential = credential as? MSALCredential {
                authPolicy = BearerTokenCredentialPolicy(credential: oauthCredential, scopes: defaultScopes)
                baseUrl = accountUrl
            } else {
                throw AzureError.general("Invalid credential. \(type(of: credential))")
            }
            super.init(
                baseUrl: baseUrl,
                transport: UrlSessionTransport(),
                policies: [
                    // Python: QueueMessagePolicy(),
                    HeadersPolicy(),
                    // Python: config.proxy_policy,
                    UserAgentPolicy(),
                    // Python: StorageContentValidation(),
                    // Python: StorageRequestHook(**kwargs),
                    authPolicy,
                    ContentDecodePolicy(),
                    // Python: RedirectPolicy(**kwargs),
                    // Python: StorageHosts(hosts=self._hosts, **kwargs),
                    // Python: config.retry_policy,
                    LoggingPolicy(
                        allowHeaders: BlobHeadersAndQueryParameters.headers,
                        allowQueryParams: BlobHeadersAndQueryParameters.queryParameters
                    )
                    // Python: StorageResponseHook(**kwargs),
                    // Python: DistributedTracingPolicy(**kwargs),
                    // Python: HttpLoggingPolicy()
                ],
                logger: self.options.logger)
    }

    /**
     Create a Storage blob data client.
     - Parameter connectionString: Storage account connection string. **WARNING**: Connection strings
     are inherently insecure in a mobile app. Any connection strings used should be read-only and not have write permissions.
     - Parameter options: A `StorageBlobClientOptions` object to control the download.
     - Returns: A `StorageBlobClient` object.
     */
    public static func from(connectionString: String, withOptions options: StorageBlobClientOptions? = nil) throws
        -> StorageBlobClient {
            let sasCredential = try StorageSASCredential(connectionString: connectionString)
            guard let blobEndpoint = sasCredential.blobEndpoint else {
                throw AzureError.general("Invalid connection string.")
            }
            return try self.init(accountUrl: blobEndpoint, credential: sasCredential, withOptions: options)
    }

    // MARK: Private Methods

    private func parse(url: URL) throws -> (String, String, String) {
        let pathComps = url.pathComponents
        guard let host = url.host else {
            throw AzureError.general("No host found for URL: \(url.absoluteString)")
        }
        guard let scheme = url.scheme else {
            throw AzureError.general("No scheme found for URL: \(url.absoluteString)")
        }
        let container = pathComps[1]
        let blobComps = pathComps[2..<pathComps.endIndex]
        let blob = Array(blobComps).joined(separator: "/")
        return ("\(scheme)://\(host)/", container, blob)
    }

    // MARK: Public Methods

    /**
     List storage containers in a storage account.
     - Parameter options: A `ListContainerOptions` object to control the list operation.
     - Parameter completion: An `HttpResultHandler` closure that returns a `PagedCollection<ContainerItem>` object on success.
     */
    public func listContainers(withOptions options: ListContainersOptions? = nil,
                               then completion: @escaping HttpResultHandler<PagedCollection<ContainerItem>>) {
        // Construct URL
        let urlTemplate = ""
        let url = format(urlTemplate: urlTemplate)

        // Construct query
        var queryParams = [String: String]()
        queryParams["comp"] = "list"

        // Construct headers
        var headerParams = HttpHeaders()
        headerParams[HttpHeader.accept] = "application/xml"
        headerParams[HttpHeader.apiVersion] = self.options.apiVersion

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
            ContextKey.xmlMap.rawValue: xmlMap as AnyObject
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

    /**
     List storage blobs within a storage container.
     - Parameter options: A `ListBlobsOptions` object to control the list operation.
     - Parameter completion: An `HttpResultHandler` closure that returns a `PagedCollection<BlobItem>` object on success.
     */
    public func listBlobs(in container: String, withOptions options: ListBlobsOptions? = nil,
                          then completion: @escaping HttpResultHandler<PagedCollection<BlobItem>>) {
        // Construct URL
        let urlTemplate = "{container}"
        let pathParams = [
            "container": container
        ]
        let url = format(urlTemplate: urlTemplate, withKwargs: pathParams)

        // Construct query
        var queryParams = [String: String]()
        queryParams["comp"] = "list"
        queryParams["resType"] = "container"

        // Construct headers
        var headerParams = HttpHeaders()
        headerParams[HttpHeader.accept] = "application/xml"
        headerParams[HttpHeader.transferEncoding] = "chunked"
        headerParams[HttpHeader.apiVersion] = self.options.apiVersion

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
            ContextKey.xmlMap.rawValue: xmlMap as AnyObject
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

    /**
     Download a blob from a specific container.
     - Parameter blob: The name of the blob.
     - Parameter fromContainer: The name of the container.
     - Parameter withOptions: A `DownloadBlobOptions` object to control the download operation.
     - Parameter then: An `HttpResultHandler` closure that returns a `BlobStreamDownloader` object on success.
     */
    public func download(blob: String, fromContainer container: String, withOptions options: DownloadBlobOptions? = nil,
                         then completion: @escaping HttpResultHandler<BlobStreamDownloader>) throws {
        let downloader = try BlobStreamDownloader(client: self, name: blob, container: container, options: options)
        downloader.initialRequest { result, httpResponse in
            switch result {
            case .success:
                completion(.success(downloader), httpResponse)
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        }
    }

    /**
     Download a blob from a given URL.
     - Parameter url: A URL to a blob to download.
     - Parameter options: A `DownloadBlobOptions` object to control the download operation.
     - Parameter completion: An `HttpResultHandler` closure that returns a `BlobStreamDownloader` object on success.
     */
    public func download(url: URL, withOptions options: DownloadBlobOptions? = nil,
                         then completion: @escaping HttpResultHandler<BlobStreamDownloader>) throws {
        let (host, container, blob) = try parse(url: url)
        if baseUrl == host {
            try download(blob: blob, fromContainer: container, withOptions: options, then: completion)
        } else {
            // TODO: Test and reconsider this implemenation for the public URL scenario.
            let client = try StorageBlobClient(accountUrl: host,
                                               credential: credential,
                                               withOptions: self.options)
            try client.download(blob: blob, fromContainer: container, withOptions: options, then: completion)
        }
    }

    /**
     Create a simple URL for a blob.
     - Parameter blob: Name of the blob.
     - Parameter container: Name of the container.
     - Returns: The URL of the blob.
     */
    public func url(forBlob blob: String, inContainer container: String) -> URL? {
        var url = URL(string: baseUrl)
        url?.appendPathComponent(container)
        url?.appendPathComponent(blob)
        return url
    }
}
