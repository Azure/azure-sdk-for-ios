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

import CoreData
import Foundation

public class BlockTransfer: NSManagedObject, Transfer {
    public var operation: ResumableTransfer?

    public var debugString: String {
        return "\t\tTransfer \(type(of: self)) \(hash): Status \(state.string())"
    }
}

extension BlockTransfer {
    public convenience init(
        withContext context: NSManagedObjectContext,
        startRange: Int64,
        endRange: Int64,
        parent: BlobTransfer? = nil
    ) {
        self.init(context: parent?.managedObjectContext ?? context)
        self.startRange = startRange
        self.endRange = endRange
//        if parent != nil {
//            let expectedEntity = entity.relationshipsByName["parent"]!.destinationEntity!
//            let actualEntity = parent!.entity
//            assert(actualEntity === expectedEntity)
//        }
        self.parent = parent
        self.state = .pending
    }
}
