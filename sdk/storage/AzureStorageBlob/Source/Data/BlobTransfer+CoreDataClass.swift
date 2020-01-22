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

public class BlobTransfer: NSManagedObject, Transfer {
    // MARK: Properties

    public var operation: ResumableTransfer?

    public var transfers: [BlockTransfer] {
        guard let blockSet = blocks else { return [BlockTransfer]() }
        return blockSet.map { $0 as? BlockTransfer }.filter { $0 != nil }.map { $0! }
    }

    public var incompleteBlocks: Int64 {
        return Int64(transfers.filter { $0.state != .complete }.count)
    }

    public var debugString: String {
        var string = "\tTransfer \(type(of: self)) \(hash): Status \(state.string())"
        for block in transfers {
            string += "\n\(block.debugString)"
        }
        return string
    }

    public var state: TransferState {
        get {
            let currState = TransferState(rawValue: rawState) ?? .unknown
            var state = currState
            for item in transfers {
                switch item.state {
                case .canceled, .failed, .paused, .inProgress:
                    state = item.state
                default:
                    continue
                }
            }
            return state
        }

        set {
            rawState = newValue.rawValue
        }
    }
}

extension BlobTransfer {
    public convenience init(
        withContext context: NSManagedObjectContext,
        baseUrl: String,
        blobName: String,
        containerName: String,
        uri: URL?,
        startRange: Int64,
        endRange: Int64,
        parent: MultiBlobTransfer? = nil
    ) {
        self.init(context: context)
        self.parent = parent
        self.baseUrl = baseUrl
        self.blobName = blobName
        self.containerName = containerName
        self.uri = uri
        self.startRange = startRange
        self.endRange = endRange
        self.state = .pending
    }
}
