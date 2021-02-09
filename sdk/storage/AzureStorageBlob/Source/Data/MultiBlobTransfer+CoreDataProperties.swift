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

extension MultiBlobTransfer {
    @nonobjc class func fetchRequest() -> NSFetchRequest<MultiBlobTransfer> {
        return NSFetchRequest<MultiBlobTransfer>(entityName: "MultiBlobTransfer")
    }

    @NSManaged var id: UUID
    @NSManaged var rawState: Int16
    @NSManaged var totalBlobs: Int64
    @NSManaged var blobs: NSSet?
}

// MARK: Generated accessors for blobs

internal extension MultiBlobTransfer {
    @objc(addBlobsObject:)
    @NSManaged func addToBlobs(_ value: BlobTransfer)

    @objc(removeBlobsObject:)
    @NSManaged func removeFromBlobs(_ value: BlobTransfer)

    @objc(addBlobs:)
    @NSManaged func addToBlobs(_ values: NSSet)

    @objc(removeBlobs:)
    @NSManaged func removeFromBlobs(_ values: NSSet)
}
