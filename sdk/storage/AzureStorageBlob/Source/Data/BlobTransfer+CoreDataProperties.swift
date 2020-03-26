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

extension BlobTransfer {
    @nonobjc internal class func fetchRequest() -> NSFetchRequest<BlobTransfer> {
        return NSFetchRequest<BlobTransfer>(entityName: "BlobTransfer")
    }

    @NSManaged internal var destination: URL?
    @NSManaged internal var endRange: Int64
    @NSManaged internal var error: Error?
    @NSManaged internal var id: UUID
    @NSManaged internal var initialCallComplete: Bool
    @NSManaged internal var rawState: Int16
    @NSManaged internal var rawType: Int16
    @NSManaged internal var source: URL?
    @NSManaged internal var startRange: Int64
    @NSManaged internal var totalBlocks: Int64
    @NSManaged internal var blocks: NSSet?
    @NSManaged internal var parent: MultiBlobTransfer?
}

// MARK: Generated accessors for blocks

extension BlobTransfer {
    @objc(addBlocksObject:)
    @NSManaged internal func addToBlocks(_ value: BlockTransfer)

    @objc(removeBlocksObject:)
    @NSManaged internal func removeFromBlocks(_ value: BlockTransfer)

    @objc(addBlocks:)
    @NSManaged internal func addToBlocks(_ values: NSSet)

    @objc(removeBlocks:)
    @NSManaged internal func removeFromBlocks(_ values: NSSet)
}
