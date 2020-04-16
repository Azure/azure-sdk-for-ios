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

extension URLSessionTransferManager: TransferDelegate {
    func transfer(_ transfer: Transfer, didUpdateWithState state: TransferState, andProgress progress: Float?) {
        guard let restorationId = (transfer as? TransferImpl)?.clientRestorationId else { return }
        let delegate = client(forRestorationId: restorationId) as? TransferDelegate
        switch state {
        case .failed:
            // Block transfers should propagate up to their BlobTransfer and only notify that the
            // entire Blob transfer failed.
            if let transferError = (transfer as? BlobTransfer)?.error as NSError? {
                if [-1009, -1005].contains(transferError.code) {
                    transfer.pause()
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
            if let blobTransfer = transfer as? BlobTransfer {
                let progress = blobTransfer.progress

                // avoid saving the context or sending multiple messages when the progress has not actually changed
                if blobTransfer.currentProgress < progress {
                    blobTransfer.currentProgress = progress
                    delegate?.transfer(transfer, didUpdateWithState: state, andProgress: progress)
                } else {
                    return
                }
            } else {
                delegate?.transfer(transfer, didUpdateWithState: state)
            }
        }
        saveContext()
    }

    func transfersDidUpdate(_ transfers: [Transfer]) {
        let restorationIds = transfers.compactMap { ($0 as? TransferImpl)?.clientRestorationId }
        for restorationId in Set(restorationIds) {
            guard let delegate = client(forRestorationId: restorationId) as? TransferDelegate else { continue }
            let transfersForId = transfers.filter { ($0 as? TransferImpl)?.clientRestorationId == restorationId }
            delegate.transfersDidUpdate(transfersForId)
        }
        saveContext()
    }

    func transferDidComplete(_ transfer: Transfer) {
        guard let restorationId = (transfer as? TransferImpl)?.clientRestorationId else { return }
        guard let delegate = client(forRestorationId: restorationId) as? TransferDelegate else { return }
        delegate.transferDidComplete(transfer)
        saveContext()
    }

    func transfer(_ transfer: Transfer, didFailWithError error: Error) {
        guard let restorationId = (transfer as? TransferImpl)?.clientRestorationId else { return }
        guard let delegate = client(forRestorationId: restorationId) as? TransferDelegate else { return }
        delegate.transfer(transfer, didFailWithError: error)
        saveContext()
    }

    func client(forRestorationId restorationId: String) -> PipelineClient? {
        return clients.object(forKey: restorationId as NSString)
    }
}
