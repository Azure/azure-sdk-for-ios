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

internal class BlobUploadFinalOperation: TransferOperation {
    // MARK: Initializers

    public convenience init(
        withTransfer transfer: BlobTransfer,
        queue: TransferOperationQueue,
        delegate: TransferDelegate?
    ) {
        self.init(transfer: transfer, delegate: delegate)
        self.queue = queue
        transfer.operation = self
    }

    // MARK: Public Methods

    override public func main() {
        guard let transfer = self.transfer as? BlobTransfer else { return }
        guard let uploader = transfer.uploader else { return }
        let group = DispatchGroup()
        group.enter()
        uploader.commit { result, _ in
            switch result {
            case .success:
                transfer.state = .complete
                self.notifyDelegate(withTransfer: transfer)
            case let .failure(error):
                transfer.state = .failed
                transfer.error = error
                transfer.parent?.state = .failed
                self.notifyDelegate(withTransfer: transfer)
            }
            group.leave()
        }
        group.wait()
        super.main()
    }
}
