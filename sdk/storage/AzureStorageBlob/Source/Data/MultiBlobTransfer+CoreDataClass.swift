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
//

import AzureCore
import CoreData
import Foundation

public class MultiBlobTransfer: NSManagedObject, Transfer {
    // MARK: Properties

    public var operation: ResumableTransfer?

    public var transfers: [BlobTransfer] {
        guard let blobSet = blobs else { return [BlobTransfer]() }
        return blobSet.map { $0 as? BlobTransfer }.filter { $0 != nil }.map { $0! }
    }

    public var debugString: String {
        var string = "Transfer \(type(of: self)) \(hash): Status \(state.string())"
        for blob in transfers {
            string += "\n\(blob.debugString)"
        }
        return string
    }

    public var state: TransferState {
        get {
            let currState = TransferState(rawValue: rawState) ?? .unknown
            var state = currState
            let inProgressTransfers = transfers.filter { $0.state == .inProgress }
            if inProgressTransfers.count > 0 {
                state = .inProgress
            }
            return state
        }

        set {
            rawState = newValue.rawValue
        }
    }
}

extension MultiBlobTransfer {
    public static func with(context: NSManagedObjectContext) -> MultiBlobTransfer {
        guard let transfer = NSEntityDescription.insertNewObject(
            forEntityName: "MultiBlobTransfer",
            into: context
        ) as? MultiBlobTransfer else {
            fatalError("Unable to create MultiBlobTransfer object.")
        }
        transfer.state = .pending
        return transfer
    }
}
