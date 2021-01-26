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

public protocol StorageBlobClientDelegate: AnyObject {
    /// A blob transfer's state and/or progress have changed.
    /// - Parameters:
    ///   - client: The `StorageBlobClient` associated with the transfer.
    ///   - transfer: The `BlobTransfer` that has changed.
    ///   - state: The `TransferState` of the blob transfer.
    ///   - progress: The `TransferProgress` of the blob transfer.
    func blobClient(
        _ client: StorageBlobClient,
        didUpdateTransfer transfer: BlobTransfer,
        withState state: TransferState,
        andProgress progress: TransferProgress
    )

    /// A blob transfer has finished.
    /// - Parameters:
    ///   - client: The `StorageBlobClient` associated with the transfer.
    ///   - transfer: The `BlobTransfer` that has completed.
    func blobClient(_ client: StorageBlobClient, didCompleteTransfer transfer: BlobTransfer)

    /// A blob transfer has failed.
    /// - Parameters:
    ///   - client: The `StorageBlobClient` associated with the transfer.
    ///   - transfer: The `BlobTransfer` that failed.
    ///   - error: The `Error` associated with the failure.
    func blobClient(_ client: StorageBlobClient, didFailTransfer transfer: BlobTransfer, withError error: Error)
}

// Do-nothing default implementations of delegate methods
public extension StorageBlobClientDelegate {
    func blobClient(
        _: StorageBlobClient,
        didUpdateTransfer _: BlobTransfer,
        withState _: TransferState,
        andProgress _: TransferProgress
    ) {}
    func blobClient(_: StorageBlobClient, didCompleteTransfer _: BlobTransfer) {}
    func blobClient(_: StorageBlobClient, didFailTransfer _: BlobTransfer, withError _: Error) {}
}
