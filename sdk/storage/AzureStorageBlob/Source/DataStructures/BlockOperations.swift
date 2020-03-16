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

public class BlockOperation: ResumableTransfer {
    // MARK: Initializers

    public convenience init(withTransfer transfer: BlockTransfer) {
        self.init(state: transfer.state)
        self.transfer = transfer
        transfer.operation = self
    }

    // MARK: Internal Methods

    internal func notifyDelegate(withTransfer transfer: BlockTransfer) {
        if let parent = transfer.parent?.operation {
            // Notify blob transfer instead of block.
            delegate?.operation(parent, didChangeState: transfer.state)
        } else {
            delegate?.operation(self, didChangeState: transfer.state)
        }
    }

    // MARK: Public Methods

    public override func main() {
        guard let transfer = transfer as? BlockTransfer else { return }
        if isCancelled || isPaused { return }
        transfer.state = .inProgress
        transfer.parent?.state = .inProgress
        notifyDelegate(withTransfer: transfer)
        if isCancelled || isPaused { return }
        let group = DispatchGroup()
        group.enter()
        if let downloader = transfer.parent?.downloader {
            let chunkDownloader = ChunkDownloader(
                blob: downloader.blobName,
                container: downloader.containerName,
                client: downloader.client,
                url: downloader.downloadDestination,
                startRange: Int(transfer.startRange),
                endRange: Int(transfer.endRange),
                options: downloader.options
            )
            chunkDownloader.download { result, _ in
                switch result {
                case .success:
                    self.delegate?.operation(self, didChangeState: .inProgress)
                case .failure:
                    self.transfer?.state = .failed
                    // TODO: The failure needs to propagate to the entire operation...
                    self.delegate?.operation(self, didChangeState: .failed)
                }
                group.leave()
            }
        } else {
            // TODO: Remove dummy workload when TM has sufficient testing
            let delay = UInt32.random(in: 5 ... 10)
            print("Simulating work with \(delay) second delay.")
            sleep(delay)
            group.leave()
        }
        group.wait()
        print("Block \(transfer.hash): Completed!")
        transfer.state = .complete
        notifyDelegate(withTransfer: transfer)
        super.main()
    }
}
