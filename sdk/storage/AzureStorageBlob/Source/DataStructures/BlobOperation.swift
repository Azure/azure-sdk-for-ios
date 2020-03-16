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

internal class BlobOperation: ResumableTransfer {
    // MARK: Initializers

    public convenience init(withTransfer transfer: BlobTransfer, queue: ResumableOperationQueue) {
        self.init(state: transfer.state)
        self.transfer = transfer
        self.operationQueue = queue
        transfer.operation = self
    }

    // MARK: Public Methods

    public override func main() {
        guard let transfer = self.transfer as? BlobTransfer else { return }
        transfer.state = .complete
        delegate?.operation(self, didChangeState: transfer.state)
        super.main()
    }
}

internal class BlobInitialOperation: ResumableTransfer {
    // MARK: Initializers

    public convenience init(withTransfer transfer: BlobTransfer, queue: ResumableOperationQueue) {
        self.init(state: transfer.state)
        self.transfer = transfer
        self.operationQueue = queue
        transfer.operation = self
    }

    // MARK: Internal Methods

    internal func queueRemainingBlocks(forTransfer transfer: BlobTransfer, withBlockList blockList: [Range<Int>]) {
        guard let operation = transfer.operation else { return }
        guard let context = transfer.managedObjectContext else { return }

        var operations = [BlockOperation]()
        for block in blockList {
            let blockTransfer = BlockTransfer.with(
                context: context,
                startRange: Int64(block.startIndex),
                endRange: Int64(block.endIndex),
                parent: transfer
            )
            transfer.blocks?.adding(blockTransfer)
            let blockOperation = BlockOperation(withTransfer: blockTransfer)
            operation.addDependency(blockOperation)
            operations.append(blockOperation)
        }
        operationQueue?.add(operations)
        transfer.totalBlocks = Int64(transfer.transfers.count)
    }

    // MARK: Public Methods

    public override func main() {
        guard let transfer = self.transfer as? BlobTransfer else { return }
        transfer.state = .inProgress
        delegate?.operation(self, didChangeState: transfer.state)
        let group = DispatchGroup()
        group.enter()
        if let downloader = transfer.downloader {
            downloader.initialRequest { result, _ in
                switch result {
                case .success:
                    self.delegate?.operation(self, didChangeState: .inProgress)
                    self.queueRemainingBlocks(forTransfer: transfer, withBlockList: downloader.blockList)
                    group.leave()
                case .failure:
                    self.transfer?.state = .failed
                    // TODO: The failure needs to propagate to the entire operation...
                    self.delegate?.operation(self, didChangeState: .failed)
                    group.leave()
                }
            }
        } else {
            // TODO: Remove dummy workload when TM has sufficient testing
            let delay = UInt32.random(in: 5 ... 10)
            print("Simulating work with \(delay) second delay.")
            sleep(delay)
            group.leave()
        }
        group.wait()
        super.main()
    }
}
