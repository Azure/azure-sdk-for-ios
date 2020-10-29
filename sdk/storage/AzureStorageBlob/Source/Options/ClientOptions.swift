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

/// User-configurable options for the `StorageBlobClient`.
public struct StorageBlobClientOptions: ClientOptions {
    /// The API version of the Azure Storage Blob service to invoke.
    public let apiVersion: String
    /// The `ClientLogger` to be used by this `StorageBlobClient`.
    public let logger: ClientLogger
    /// Options for configuring telemetry sent by this `StorageBlobClient`.
    public let telemetryOptions: TelemetryOptions
    /// Global transport options
    public let transportOptions: TransportOptions
    /// A dispatch queue on which to call all completion handlers. Defaults to `DispatchQueue.main`.
    public let dispatchQueue: DispatchQueue?

    // Blob operations

    /// An identifier used to associate this client with transfers it creates. When a transfer is reloaded from disk
    /// (e.g. after an application crash), it can only be resumed once a client with the same `restorationId` has been
    /// initialized. If your application only uses a single `StorageBlobClient`, it is recommended to use a value unique
    /// to your application (e.g. "MyApplication"). If your application uses multiple clients with different
    /// configurations, use a value unique to both your application and the configuration (e.g.
    /// "MyApplication.userClient").
    public let restorationId: String

    /// The maximum size of a single chunk in a blob upload or download.
    public let maxChunkSizeInBytes: Int

    /// The `TransferNetworkPolicy` to use for managed downloads.
    public let downloadNetworkPolicy: TransferNetworkPolicy

    /// The `TransferNetworkPolicy` to use for managed uploads.
    public let uploadNetworkPolicy: TransferNetworkPolicy

    /// Initialize a `StorageBlobClientOptions` structure.
    /// - Parameters:
    ///   - apiVersion: The API version of the Azure Storage Blob service to invoke.
    ///   - logger: The `ClientLogger` to be used by this `StorageBlobClient`.
    ///   - telemetryOptions: Options for configuring telemetry sent by this `StorageBlobClient`.
    ///   - transportOptions: Global transport options
    ///   - dispatchQueue: A dispatch queue on which to call all completion handlers. Defaults to `DispatchQueue.main`.
    ///   - restorationId: An identifier used to associate this client with transfers it creates. When a transfer is
    ///     reloaded from disk (e.g. after an application crash), it can only be resumed once a client with the same
    ///     `restorationId` has been initialized. If your application only uses a single `StorageBlobClient`, it is
    ///     recommended to use a value unique to your application (e.g. "MyApplication"). If your application uses
    ///     multiple clients with different configurations, use a value unique to both your application and the
    ///     configuration (e.g. "MyApplication.userClient").
    ///   - maxChunkSizeInBytes: The maximum size of a single chunk in a blob upload or download.
    ///     Must be less than 4MB if enabling MD5 or CRC64 hashing.
    ///   - downloadNetworkPolicy: The `TransferNetworkPolicy` to use for managed downloads.
    ///   - uploadNetworkPolicy: The `TransferNetworkPolicy` to use for managed uploads.
    public init(
        apiVersion: StorageBlobClient.ApiVersion = .latest,
        logger: ClientLogger = ClientLoggers.default(tag: "StorageBlobClient"),
        telemetryOptions: TelemetryOptions = TelemetryOptions(),
        transportOptions: TransportOptions? = nil,
        dispatchQueue: DispatchQueue? = nil,
        restorationId: String = DeviceProviders.appBundleInfo.identifier ?? "AzureStorageBlob",
        maxChunkSizeInBytes: Int = 4 * 1024 * 1024 - 1,
        downloadNetworkPolicy: TransferNetworkPolicy? = nil,
        uploadNetworkPolicy: TransferNetworkPolicy? = nil
    ) {
        self.apiVersion = apiVersion.rawValue
        self.logger = logger
        self.telemetryOptions = telemetryOptions
        self.transportOptions = transportOptions ?? TransportOptions()
        self.dispatchQueue = dispatchQueue
        self.maxChunkSizeInBytes = maxChunkSizeInBytes
        self.restorationId = restorationId
        self.downloadNetworkPolicy = downloadNetworkPolicy ?? TransferNetworkPolicy.default
        self.uploadNetworkPolicy = uploadNetworkPolicy ?? TransferNetworkPolicy.default
    }
}
