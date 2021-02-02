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

// swiftlint:disable type_body_length function_body_length
public final class ContainersOperations {
    let client: StorageBlobClient

    required init(_ client: StorageBlobClient) {
        self.client = client
    }

    /// List storage containers in a storage account.
    /// - Parameters:
    ///   - options: A `ListContainersOptions` object to control the list operation.
    ///   - completionHandler: A completion handler that receives a `PagedCollection` of `ContainerItem` objects on
    ///     success.
    public func list(
        withOptions options: ListContainersOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ContainerItem>>
    ) {
        // Construct URL
        let urlTemplate = ""
        let params = RequestParameters(
            (.query, "comp", "list", .encode),
            (.header, HTTPHeader.accept, "application/xml", .encode),
            (.header, HTTPHeader.apiVersion, client.options.apiVersion, .encode),
            (.query, "prefix", options?.prefix, .encode),
            (.query, "include", options?.include, .encode),
            (.query, "maxresults", options?.maxResults, .encode),
            (.query, "timeout", options?.timeout, .encode),
            (.header, HTTPHeader.clientRequestId, options?.clientRequestId, .encode)
        )

        // Construct and send request
        let codingKeys = PagedCodingKeys(
            items: "EnumerationResults.Containers",
            continuationToken: "EnumerationResults.NextMarker",
            xmlItemName: "Container"
        )
        let xmlMap = XMLMap(withPagedCodingKeys: codingKeys, innerType: ContainerItem.self)
        let context = PipelineContext.of(keyValues: [
            ContextKey.xmlMap.rawValue: xmlMap as AnyObject,
            ContextKey.xmlErrorMap.rawValue: StorageError.xmlMap() as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
        context.merge(with: options?.context)
        guard let requestUrl = client.url(template: urlTemplate, params: params),
            let request = try? HTTPRequest(method: .get, url: requestUrl, headers: params.headers) else {
            client.options.logger.error("Failed to construct Http request")
            return
        }

        client.request(request, context: context) { result, httpResponse in
            let dispatchQueue = options?.dispatchQueue ?? self.client.commonOptions.dispatchQueue ?? DispatchQueue.main
            switch result {
            case let .success(data):
                guard let data = data else {
                    let noDataError = AzureError.client("Response data expected but not found.")
                    dispatchQueue.async {
                        completionHandler(.failure(noDataError), httpResponse)
                    }
                    return
                }
                do {
                    let decoder = StorageJSONDecoder()
                    let paged = try PagedCollection<ContainerItem>(
                        client: self.client,
                        request: request,
                        context: context,
                        data: data,
                        codingKeys: codingKeys,
                        decoder: decoder
                    )
                    dispatchQueue.async {
                        completionHandler(.success(paged), httpResponse)
                    }
                } catch {
                    dispatchQueue.async {
                        completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                    }
                }
            case let .failure(error):
                dispatchQueue.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }

    /// Create a storage container in a storage account.
    /// - Parameters:
    ///   - container: The container name to create.
    ///   - options: A `CreateContainerOptions` object to control the create operation.
    ///   - completionHandler: A completion handler that receives a `ContainerProperties` object on
    ///     success.
    public func create(
        container: String,
        withOptions options: CreateContainerOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<ContainerProperties>
    ) {
        let urlTemplate = "{container}"
        let params = RequestParameters(
            (.path, "container", container, .encode),
            (.query, "restype", "container", .encode),
            (.query, "timeout", options?.timeout, .encode),
            (.header, HTTPHeader.apiVersion, client.options.apiVersion, .encode),
            (.header, HTTPHeader.clientRequestId, options?.clientRequestId, .encode),
            (.header, StorageHTTPHeader.metadata, options?.metadata, .encode),
            (.header, StorageHTTPHeader.blobPublicAccess, options?.access, .encode),
            (
                .header,
                StorageHTTPHeader.defaultEncryptionScope,
                options?.containerCpkScopeInfo?.defaultEncryptionScope,
                .encode
            ),
            (
                .header,
                StorageHTTPHeader.denyEncryptionScopeOverride,
                options?.containerCpkScopeInfo?.preventEncryptionScopeOverride,
                .encode
            )
        )

        // Construct and send request
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [201] as AnyObject,
            ContextKey.xmlErrorMap.rawValue: StorageError.xmlMap() as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
        context.merge(with: options?.context)

        guard let requestUrl = client.url(template: urlTemplate, params: params),
            let request = try? HTTPRequest(method: .put, url: requestUrl, headers: params.headers) else {
            client.options.logger.error("Failed to construct Http request")
            return
        }
        client.request(request, context: context) { result, httpResponse in
            let dispatchQueue = options?.dispatchQueue ?? self.client.commonOptions.dispatchQueue ?? DispatchQueue.main
            switch result {
            case .success:
                guard let headers = httpResponse?.headers,
                    let properties = ContainerProperties(from: headers) else {
                    completionHandler(.failure(AzureError.client("Properties not found.", nil)), httpResponse)
                    return
                }
                dispatchQueue.async {
                    completionHandler(.success(properties), httpResponse)
                }
            case let .failure(error):
                dispatchQueue.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }

    /// Get a storage container in a storage account.
    /// - Parameters:
    ///   - container: The container name to get.
    ///   - options: A `GetContainerOptions` object to control the get operation.
    ///   - completionHandler: A completion handler that receives a `ContainerProperties` object on
    ///     success.
    public func get(
        container: String,
        withOptions options: GetContainerOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<ContainerProperties>
    ) {
        let urlTemplate = "{container}"
        let params = RequestParameters(
            (.path, "container", container, .encode),
            (.query, "restype", "container", .encode),
            (.query, "timeout", options?.timeout, .encode),
            (.header, HTTPHeader.apiVersion, client.options.apiVersion, .encode),
            (.header, StorageHTTPHeader.leaseId, options?.leaseAccessConditions?.leaseId, .encode),
            (.header, HTTPHeader.clientRequestId, options?.clientRequestId, .encode)
        )

        // Construct and send request
        let xmlMap = ContainerItem.xmlMap()
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [200] as AnyObject,
            ContextKey.xmlMap.rawValue: xmlMap as AnyObject,
            ContextKey.xmlErrorMap.rawValue: StorageError.xmlMap() as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
        context.merge(with: options?.context)
        guard let requestUrl = client.url(template: urlTemplate, params: params),
            let request = try? HTTPRequest(method: .get, url: requestUrl, headers: params.headers) else {
            client.options.logger.error("Failed to construct Http request")
            return
        }
        client.request(request, context: context) { result, httpResponse in
            let dispatchQueue = options?.dispatchQueue ?? self.client.commonOptions.dispatchQueue ?? DispatchQueue.main

            switch result {
            case .success:
                guard let headers = httpResponse?.headers,
                    let properties = ContainerProperties(from: headers) else {
                    completionHandler(.failure(AzureError.client("Properties not found.", nil)), httpResponse)
                    return
                }
                dispatchQueue.async {
                    completionHandler(.success(properties), httpResponse)
                }
            case let .failure(error):
                dispatchQueue.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }

    /// Delete a storage container.
    /// - Parameters:
    ///   - container: The container name to delete.
    ///   - options: A `DeleteContainerOptions` object to control the delete operation.
    ///   - completionHandler: A completion handler to notify about success or failure.
    public func delete(
        container: String,
        withOptions options: DeleteContainerOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        let urlTemplate = "{container}"
        let params = RequestParameters(
            (.path, "container", container, .encode),
            (.query, "restype", "container", .encode),
            (.query, "timeout", options?.timeout, .encode),
            (.header, HTTPHeader.apiVersion, client.options.apiVersion, .encode),
            (.header, StorageHTTPHeader.leaseId, options?.leaseAccessConditions?.leaseId, .encode),
            (.header, HTTPHeader.ifModifiedSince, options?.modifiedAccessConditions?.ifModifiedSince, .encode),
            (.header, HTTPHeader.ifUnmodifiedSince, options?.modifiedAccessConditions?.ifUnmodifiedSince, .encode),
            (.header, HTTPHeader.clientRequestId, options?.clientRequestId, .encode)
        )

        // Construct and send request
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [202] as AnyObject,
            ContextKey.xmlErrorMap.rawValue: StorageError.xmlMap() as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
        context.merge(with: options?.context)
        guard let requestUrl = client.url(template: urlTemplate, params: params),
            let request = try? HTTPRequest(method: .delete, url: requestUrl, headers: params.headers) else {
            client.options.logger.error("Failed to construct Http request")
            return
        }
        client.request(request, context: context) { result, httpResponse in
            let dispatchQueue = options?.dispatchQueue ?? self.client.commonOptions.dispatchQueue ?? DispatchQueue.main
            switch result {
            case .success:
                dispatchQueue.async {
                    completionHandler(.success(()), httpResponse)
                }
            case let .failure(error):
                dispatchQueue.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }
}
