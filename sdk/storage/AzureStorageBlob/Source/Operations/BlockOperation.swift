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
import CoreData
import Foundation

internal class BlockOperation: TransferOperation {
    // MARK: Initializers

    public convenience init(withTransfer transfer: BlockTransfer, delegate: TransferDelegate?) {
        self.init(transfer: transfer, delegate: delegate)
        self.transfer = transfer
        transfer.operation = self
    }

    // MARK: Public Methods

    override public func main() {
        guard let transfer = transfer as? BlockTransfer else {
            assertionFailure("Precondition failed for BlockOperation.")
            return
        }
        let parent = transfer.parent
        if !transfer.isActive { return }
        transfer.state = .inProgress
        parent.state = .inProgress
        notifyDelegate(withTransfer: parent)
        if !transfer.isActive { return }
        let group = DispatchGroup()
        group.enter()
        switch parent.transferType {
        case .download:
            guard let downloader = parent.downloader else {
                assertionFailure("Downloader not found for BlobOperation.")
                group.leave()
                return
            }
            let chunkDownloader = ChunkDownloader(
                client: downloader.client,
                source: downloader.downloadSource,
                destination: downloader.downloadDestination,
                startRange: Int(transfer.startRange),
                endRange: Int(transfer.endRange),
                options: downloader.options
            )
            chunkDownloader.download { result, httpResponse in
                defer { group.leave() }
                if !transfer.isActive { return }
                switch result {
                case .success:
                    guard let responseHeaders = httpResponse?.headers else {
                        assertionFailure("Response headers not found.")
                        return
                    }
                    let blobProperties = BlobProperties(from: responseHeaders)
                    let bytesTransferred = (blobProperties.contentLength ?? 1) - 1
                    downloader.progress += bytesTransferred
                    parent.bytesTransferred += Int64(bytesTransferred)
                    transfer.state = .complete
                    self.notifyDelegate(withTransfer: parent)
                case let .failure(error):
                    transfer.state = .failed
                    parent.state = .failed
                    parent.error = error
                    self.notifyDelegate(withTransfer: parent)
                }
            }
        case .upload:
            guard let uploader = parent.uploader else {
                assertionFailure("Uploader not found for BlobOperation.")
                group.leave()
                return
            }
            let chunkUploader = ChunkUploader(
                blockId: transfer.id,
                client: uploader.client,
                source: uploader.uploadSource,
                destination: uploader.uploadDestination,
                startRange: Int(transfer.startRange),
                endRange: Int(transfer.endRange),
                options: uploader.options
            )
            chunkUploader.upload { result, _ in
                defer { group.leave() }
                if !transfer.isActive { return }
                switch result {
                case .success:
                    // Add block ID to the completed list and lookup where its final
                    // placement should be
                    let blockId = chunkUploader.blockId
                    if let parentUploader = parent.uploader {
                        parentUploader.completedBlockMap[blockId] = parentUploader.blockIdMap[blockId]
                    }
                    transfer.state = .complete
                    self.notifyDelegate(withTransfer: parent)
                case let .failure(error):
                    transfer.state = .failed
                    parent.state = .failed
                    parent.error = error
                    self.notifyDelegate(withTransfer: parent)
                }
            }
        }
        group.wait()
        super.main()
    }
}
