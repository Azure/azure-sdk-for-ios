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
    func blobClient(
        _ client: StorageBlobClient,
        didUpdateTransfer transfer: BlobTransfer,
        withState state: TransferState,
        andProgress progress: Float?
    )
    func blobClient(_ client: StorageBlobClient, didCompleteTransfer transfer: BlobTransfer)
    func blobClient(_ client: StorageBlobClient, didFailTransfer transfer: BlobTransfer, withError error: Error)
}

// Do-nothing default implementations of delegate methods
extension StorageBlobClientDelegate {
    public func blobClient(
        _: StorageBlobClient,
        didUpdateTransfer _: BlobTransfer,
        withState _: TransferState,
        andProgress _: Float?
    ) {}
    public func blobClient(_: StorageBlobClient, didCompleteTransfer _: BlobTransfer) {}
    public func blobClient(_: StorageBlobClient, didFailTransfer _: BlobTransfer, withError _: Error) {}
}
