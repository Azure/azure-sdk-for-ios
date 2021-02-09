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
        let params = RequestParameters(
            (.query, "marker", token, .encode)
        )
        return requestUrl.appendingQueryParameters(params)
    }
}

// MARK: Transfer Delegate

/// :nodoc:
extension StorageBlobClient: TransferDelegate {
    /// :nodoc:
    public func transfer(
        _ transfer: Transfer,
        didUpdateWithState state: TransferState,
        andProgress _: TransferProgress?
    ) {
        if let blobTransfer = transfer as? BlobTransfer {
            delegate?.blobClient(
                self,
                didUpdateTransfer: blobTransfer,
                withState: state,
                andProgress: blobTransfer.progress
            )
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

public extension StorageBlobClient {
    /// Retrieve all managed transfers created by this client.
    var transfers: TransferCollection {
        let collection = StorageBlobClient.manager.transferCollection.items
        return TransferCollection(collection.filter { $0.clientRestorationId == self.options.restorationId })
    }

    /// Retrieve all managed downloads created by this client.
    var downloads: TransferCollection {
        let collection = StorageBlobClient.manager.downloadCollection.items
        return TransferCollection(collection.filter { $0.clientRestorationId == self.options.restorationId })
    }

    /// Retrieve all managed uploads created by this client.
    var uploads: TransferCollection {
        let collection = StorageBlobClient.manager.uploadCollection.items
        return TransferCollection(collection.filter { $0.clientRestorationId == self.options.restorationId })
    }
}
