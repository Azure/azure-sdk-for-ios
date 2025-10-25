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

// MARK: XML Tree

class XMLTree {
    var root = XMLTreeNode(name: "__ROOT__", type: .ignored, parent: nil)

    var dictionary: [String: Any]? {
        return root.dictionary
    }

    var array: [Any]? {
        return root.array
    }
}

// MARK: XML Tree Node

class XMLTreeNode {
    var dictionary: [String: Any]? {
        var propDict = [String: Any]()
        for (key, metadata) in properties {
            assert(metadata.parent == nil, "Unexpectedly found a parent reference, which could leak to memory leaks.")
            switch metadata.type {
            case .property:
                propDict[key] = metadata.value
            case .object, .arrayItem, .anyObject:
                if let dictValue = metadata.dictionary {
                    propDict[key] = dictValue
                } else {
                    fatalError("Failed to get dictionary version of object.")
                }
            case .array:
                if let arrayValue = metadata.array {
                    propDict[key] = arrayValue
                } else {
                    fatalError("Failed to get array version of object.")
                }
            case .ignored:
                break
            case .flatten:
                if let dictValue = metadata.dictionary {
                    propDict = dictValue
                } else {
                    fatalError("Failed to get dictionary version of object.")
                }
            }
        }
        return propDict
    }

    var array: [Any]? {
        var array = [Any]()
        for item in collection {
            if let itemDict = item.dictionary {
                array.append(itemDict)
            }
        }
        return array
    }

    var name: String
    var type: ElementToJsonStrategy
    var value: String
    var properties = [String: XMLTreeNode]()
    var collection = [XMLTreeNode]()
    var parent: XMLTreeNode?

    init(name: String, type: ElementToJsonStrategy, parent: XMLTreeNode?, value: String = "") {
        self.name = name
        self.parent = parent
        self.value = value
        self.type = type
    }
}
