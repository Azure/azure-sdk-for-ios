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

import CoreData
import Foundation

internal class TransferOperation: Operation {
    // MARK: Properties

    public var transfer: TransferImpl
    public weak var delegate: TransferDelegate?
    public weak var queue: TransferOperationQueue?

    // MARK: Initializers

    public init(transfer: TransferImpl, delegate: TransferDelegate?) {
        self.transfer = transfer
        self.delegate = delegate
    }

    // MARK: Public Methods

    override open func main() {
        if !transfer.isActive { return }
        super.main()
    }

    // MARK: Internal Methods

    internal func notifyDelegate(withTransfer transfer: BlobTransfer) {
        delegate?.transfer(transfer, didUpdateWithState: transfer.state, andProgress: transfer.progress)
    }
}
