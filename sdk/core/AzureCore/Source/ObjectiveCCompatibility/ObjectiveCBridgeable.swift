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

import Foundation

/// This protocol is used internally to expose a Swift
/// type to a type that is representable in Objective-C
/// as the type `ObjectiveCType` or one of its subclasses.
public protocol ObjectiveCBridgeable {

    // MARK: Required Properties

    /// The type corresponding to `Self` in Objective-C.
    associatedtype ObjectiveCType: AnyObject

    // MARK: Required Initializers

    /// Reconstructs a Swift value of type `Self`
    /// from its corresponding value of type
    /// `ObjectiveCType`.
    init(bridgedFromObjectiveC: ObjectiveCType)

    // MARK: Required Methods

    /// Converts `self` to its corresponding
    /// `ObjectiveCType`.
    func bridgeToObjectiveC() -> ObjectiveCType
}
