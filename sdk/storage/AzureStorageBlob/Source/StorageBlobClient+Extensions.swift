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

// MARK: PageableClient

/// :nodoc:
extension StorageBlobClient: PageableClient {
    /// :nodoc:
    public func continuationUrl(forRequestUrl requestUrl: URL, withContinuationToken token: String) -> URL? {
        return requestUrl.appendingQueryParameters([("marker", token)])
    }
}

// MARK: Transfer Delegate

/// :nodoc:
extension StorageBlobClient: TransferDelegate {
    /// :nodoc:
    public func transfer(
        _ transfer: Transfer,
        didUpdateWithState state: TransferState,
        andProgress progress: Float?
    ) {
        if let blobTransfer = transfer as? BlobTransfer {
            delegate?.blobClient(self, didUpdateTransfer: blobTransfer, withState: state, andProgress: progress)
        }
    }

    /// :nodoc:
    public func transfer(_ transfer: Transfer, didFailWithError error: Error) {
        if let blobTransfer = transfer as? BlobTransfer {
            delegate?.blobClient(self, didFailTransfer: blobTransfer, withError: error)
        }
    }

    /// :nodoc:
    public func transferDidComplete(_ transfer: Transfer) {
        if let blobTransfer = transfer as? BlobTransfer {
            delegate?.blobClient(self, didCompleteTransfer: blobTransfer)
        }
    }
}

// MARK: Transfer Management

extension StorageBlobClient {
    /// Start the transfer management engine.
    ///
    /// Loads transfer state from disk, begins listening for network connectivity events, and resumes any incomplete
    /// transfers. This method **MUST** be called by your application in order for any managed transfers to occur.
    /// It's recommended to call this method from a background thread, at an opportune time after your app has started.
    ///
    /// Note that depending on the type of credential used by this `StorageBlobClient`, resuming transfers may cause a
    /// login UI to be displayed if the token for a paused transfer has expired. Because of this, it's not recommended
    /// to call this method from your `AppDelegate`. If you're using such a credential (e.g. `MSALCredential`) you
    /// should first inspect the list of transfers to determine if any are pending. If so, you should assume that
    /// calling this method may display a login UI, and call it in a user-appropriate context (e.g. display a "pending
    /// transfers" message and wait for explicit user confirmation to start the management engine). If you're not using
    /// such a credential, or there are no paused transfers, it is safe to call this method from your `AppDelegate`.
    public static func startManaging() {
        StorageBlobClient.manager.startManaging()
    }

    /// Stop the transfer management engine.
    ///
    /// Pauses all incomplete transfers, stops listening for network connectivity events, and stores transfer state to
    /// disk. This method **SHOULD** be called by your application, either from your `AppDelegate` or from within a
    /// `ViewController`'s lifecycle methods.
    public static func stopManaging() {
        StorageBlobClient.manager.stopManaging()
    }

    /// Retrieve all managed transfers created by this client.
    public var transfers: TransferCollection {
        let matching: [BlobTransfer] = StorageBlobClient.manager.transfers.compactMap { transfer in
            guard let transfer = transfer as? BlobTransfer else { return nil }
            return transfer.clientRestorationId == restorationId ? transfer : nil
        }
        return TransferCollection(matching)
    }

    /// Retrieve all managed downloads created by this client.
    public var downloads: TransferCollection {
        let matching: [BlobTransfer] = StorageBlobClient.manager.transfers.compactMap { transfer in
            guard let transfer = transfer as? BlobTransfer else { return nil }
            return transfer.clientRestorationId == restorationId && transfer.transferType == .download ? transfer : nil
        }
        return TransferCollection(matching)
    }

    /// Retrieve all managed uploads created by this client.
    public var uploads: TransferCollection {
        let matching: [BlobTransfer] = StorageBlobClient.manager.transfers.compactMap { transfer in
            guard let transfer = transfer as? BlobTransfer else { return nil }
            return transfer.clientRestorationId == restorationId && transfer.transferType == .upload ? transfer : nil
        }
        return TransferCollection(matching)
    }
}
