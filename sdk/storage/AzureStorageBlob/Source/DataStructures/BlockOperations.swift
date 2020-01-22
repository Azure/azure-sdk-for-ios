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

    // MARK: Public Methods

    public override func main() {
        guard let transfer = transfer as? BlockTransfer else { return }
        if isCancelled || isPaused { return }
        transfer.state = .inProgress
        transfer.parent?.state = .inProgress
        delegate?.operation(self, didChangeState: transfer.state)
        let delay = UInt32.random(in: 5 ... 10)
        print("Block \(transfer.hash): Simulating work with \(delay) second delay.")
        sleep(delay)
        if isCancelled || isPaused { return }
        transfer.data = UUID().uuidString.data(using: .utf8)
        print("Block \(transfer.hash): Completed!")
        transfer.state = .complete
        delegate?.operation(self, didChangeState: transfer.state)
        super.main()
    }
}
