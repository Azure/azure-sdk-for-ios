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

extension URLSessionTransferManager: ResumableOperationQueueDelegate {
    private func buildProgressInfo(forTransfer transfer: Transfer) -> TransferProgress? {
        guard let blobTransfer = transfer as? BlobTransfer else { return nil }
        switch blobTransfer.transferType {
        case .upload:
            let blocks = blobTransfer.totalBlocks - blobTransfer.incompleteBlocks
            return TransferProgress(bytes: Int(blocks), totalBytes: Int(blobTransfer.totalBlocks))
        case .download:
            guard let downloader = blobTransfer.downloader else { return nil }
            return TransferProgress(bytes: downloader.progress, totalBytes: downloader.totalSize)
        }
    }

    internal func operation(_ operation: ResumableOperation?, didChangeState state: TransferState) {
        saveContext()
        guard let transfer = operation?.transfer else { return }
        let progress = buildProgressInfo(forTransfer: transfer)
        switch state {
        case .failed:
            // Block transfers should propagate up to their BlobTransfer and only notify that the
            // entire Blob transfer failed.
            if let transferError = (transfer as? BlobTransfer)?.error as? NSError {
                if [-1009, -1005].contains(transferError.code) {
                    pause(transfer: transfer)
                } else {
                    delegate?.transfer(transfer, didFailWithError: transferError)
                }
            } else {
                // ignore BlockTransfer failures
                return
            }
        case .complete:
            delegate?.transferDidComplete(transfer)
        default:
            delegate?.transfer(transfer, didUpdateWithState: state, andProgress: progress)
        }
    }

    internal func operations(_: [ResumableOperation]?, didChangeState _: TransferState) {
        saveContext()
    }
}
