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

import Foundation

public struct TransferCollection {
    /// Get all transfers in this `TransferCollection`.
    public let items: [BlobTransfer]

    internal init(_ items: [BlobTransfer]) {
        self.items = items
    }

    /// Get a single transfer in this `TransferCollection` by its id.
    /// - Parameters:
    ///   - transferId: The id of the transfer to retrieve.
    public subscript(_ transferId: UUID) -> BlobTransfer? { return items.first { $0.id == transferId } }

    /// Cancel all currently active transfers in this `TransferCollection`.
    public func cancelAll() {
        for transfer in items {
            URLSessionTransferManager.shared.cancel(transfer: transfer)
        }
    }

    /// Remove all transfers in this `TransferCollection` from the database. All currently active transfers will be
    /// canceled.
    public func removeAll() {
        for transfer in items {
            URLSessionTransferManager.shared.remove(transfer: transfer)
        }
    }

    /// Pause all currently active transfers in this `TransferCollection`.
    public func pauseAll() {
        for transfer in items {
            URLSessionTransferManager.shared.pause(transfer: transfer)
        }
    }

    /// Resume all currently paused transfers in this `TransferCollection`.
    public func resumeAll(progressHandler: ((BlobTransfer) -> Void)? = nil) {
        for transfer in items {
            URLSessionTransferManager.shared.resume(transfer: transfer, progressHandler: progressHandler)
        }
    }

    /// Get all transfers in this `TransferCollection` that match all of the provided filter values.
    /// - Parameters:
    ///   - containerName: The name of the blob container involved in the transfer. For downloads this is the source
    ///   container, whereas for uploads this is the destination container.
    ///   - blobName: The name of the blob involved in the transfer. For downloads this is the source blob, whereas for
    ///   uploads this is the destination blob.
    ///   - localUrl: The `LocalURL` involved in the transfer. For downloads this is the destination, whereas for
    ///   uploads this is the source.
    ///   - state: The current state of the transfer.
    public func filterWhere(
        containerName: String? = nil,
        blobName: String? = nil,
        localUrl: LocalURL? = nil,
        state: TransferState? = nil
    ) -> TransferCollection {
        return TransferCollection(items.filter { transfer in
            match(transfer, containerName: containerName, blobName: blobName, localUrl: localUrl, state: state)
        })
    }

    /// Get the first transfer in this `TransferCollection` that matches all of the provided filter values.
    /// - Parameters:
    ///   - containerName: The name of the blob container involved in the transfer. For downloads this is the source
    ///   container, whereas for uploads this is the destination container.
    ///   - blobName: The name of the blob involved in the transfer. For downloads this is the source blob, whereas for
    ///   uploads this is the destination blob.
    ///   - localUrl: The `LocalURL` involved in the transfer. For downloads this is the destination, whereas for
    ///   uploads this is the source.
    ///   - state: The current state of the transfer.
    public func firstWith(
        containerName: String? = nil,
        blobName: String? = nil,
        localUrl: LocalURL? = nil,
        state: TransferState? = nil
    ) -> BlobTransfer? {
        return items.first { transfer in
            match(transfer, containerName: containerName, blobName: blobName, localUrl: localUrl, state: state)
        }
    }

    private func match(
        _ transfer: BlobTransfer,
        containerName: String? = nil,
        blobName: String? = nil,
        localUrl: LocalURL? = nil,
        state: TransferState? = nil
    ) -> Bool {
        if let state = state {
            guard transfer.state == state else { return false }
        }

        if let localUrl = localUrl {
            guard let url = transfer.transferType == .download ? transfer.destination : transfer.source,
                url == localUrl.rawUrl else { return false }
        }

        if let blobName = blobName {
            guard let url = transfer.transferType == .download ? transfer.source : transfer.destination,
                url.path.hasSuffix(blobName) else { return false }
        }

        if var containerName = containerName {
            containerName = containerName.hasPrefix("/") ? containerName : "/\(containerName)"
            guard let url = transfer.transferType == .download ? transfer.source : transfer.destination,
                url.path.hasPrefix(containerName) else { return false }
        }
        return true
    }
}
