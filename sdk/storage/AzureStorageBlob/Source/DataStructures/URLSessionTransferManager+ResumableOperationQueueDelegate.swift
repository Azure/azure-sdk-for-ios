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

extension URLSessionTransferManager: ResumableOperationQueueDelegate {
    internal func buildProgressInfo(forTransfer transfer: Transfer) -> TransferProgress? {
        guard let blobTransfer = transfer as? BlobTransfer else { return nil }
        let blocks = blobTransfer.totalBlocks - blobTransfer.incompleteBlocks
        let progressInfo = BlobDownloadProgress(bytes: Int(blocks), totalBytes: Int(blobTransfer.totalBlocks))
        return progressInfo
    }

    public func operation(_ operation: ResumableOperation?, didChangeState state: TransferState) {
        if let transfer = (operation as? ResumableTransfer)?.transfer {
            transfer.state = state
            saveContext()
            let progress = buildProgressInfo(forTransfer: transfer)
            delegate?.transferManager(self, didUpdateTransfer: transfer, withState: state, andProgress: progress)
        } else {
            saveContext()
            delegate?.transferManager(self, didUpdateWithState: state)
        }
    }

    public func operations(_ operations: [ResumableOperation]?, didChangeState state: TransferState) {
        if let ops = operations {
            // pull out the operations that have associated transfers and pass them to the TransferManager delegate
            let transfers = ops.map { ($0 as? ResumableTransfer)?.transfer }.filter { $0 != nil }.map { $0! }
            for transfer in transfers {
                transfer.state = state
            }
            saveContext()
            delegate?.transferManager(self, didUpdateTransfers: transfers, withState: state)
        } else {
            saveContext()
            delegate?.transferManager(self, didUpdateWithState: state)
        }
    }
}
