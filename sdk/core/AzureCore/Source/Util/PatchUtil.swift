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

public enum PatchOpType: String, Codable {
    case add
    case remove
    case replace
    case move
    case copy
    case test
}

public struct PatchOperation: Encodable {
    let operation: PatchOpType
    let from: String?
    let path: String
    let value: Encodable?
}

/// Helper class for creating PatchObjects
public final class PatchObject: Encodable {
    fileprivate var operations: [PatchOperation]

    public init() {
        self.operations = [PatchOperation]()
    }

    /// Inserts a new value at an array index or adds a new property.
    public func add(atPath path: String, withValue value: Encodable) {
        operations.append(PatchOperation(operation: .add, from: nil, path: path, value: value))
    }

    /// Remove the property or entry at an array index. Property must exist.
    public func remove(atPath path: String) {
        operations.append(PatchOperation(operation: .remove, from: nil, path: path, value: nil))
    }

    /// Replaces the value at the target location with a new value. Existing value must exist.
    public func replace(atPath path: String, withValue value: Encodable) {
        operations.append(PatchOperation(operation: .replace, from: nil, path: path, value: value))
    }

    /// Remove the value at a specified location and adds it to the target location.
    public func move(fromPath src: String, toPath dest: String) {
        operations.append(PatchOperation(operation: .move, from: src, path: dest, value: nil))
    }

    /// Copies the value at a specified location and adds it to the target location.
    public func copy(fromPath src: String, toPath dest: String) {
        operations.append(PatchOperation(operation: .copy, from: src, path: dest, value: nil))
    }

    /// Tests that a value at the target location is equal to a specified value.
    public func test(atPath path: String, equalsValue value: AnyCodable) {
        operations.append(PatchOperation(operation: .test, from: nil, path: path, value: value))
    }
}
