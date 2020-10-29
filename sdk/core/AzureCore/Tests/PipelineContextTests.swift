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

@testable import AzureCore
import XCTest

// swiftlint:disable force_try force_cast
class PipelineContextTests: XCTestCase {
    func test_PipelineContext_CanMerge() {
        let context1 = PipelineContext.of(keyValues: ["a": 1 as AnyObject])
        let context2 = PipelineContext.of(keyValues: ["a": 2 as AnyObject, "b": 3 as AnyObject])

        // Ensure that contexts can be merged
        context1.merge(with: context2)
        XCTAssert(context1.count == 3, "Expected count 3, found \(context1.count)")

        // Ensure a subsequent value overrides an earlier one
        let aVal = context1.value(forKey: "a") as! Int
        XCTAssert(aVal == 2)

        // Ensure new values can be added
        let bVal = context1.value(forKey: "b") as! Int
        XCTAssert(bVal == 3)
    }

    func test_PipelineContext_IsIterable() {
        let context = PipelineContext()

        // Ensure values can be properly added
        context.add(value: "1" as AnyObject, forKey: "a")
        context.add(value: "2" as AnyObject, forKey: "b")
        context.add(value: "3" as AnyObject, forKey: "c")
        XCTAssert(context.count == 3, "Expected count 3, found \(context.count)")

        // Ensure foreach generates correct count
        var iterCount = 0
        for _ in context {
            iterCount += 1
        }
        XCTAssert(iterCount == context.count, "Expected count \(context.count), found \(iterCount)")
    }

    func test_PipelineContext_toDict() {
        let context = PipelineContext.of(keyValues: [
            "a": "1" as AnyObject,
            "b": "2" as AnyObject,
            "c": "3" as AnyObject
        ])

        // Ensure that toDict uses the latest value for a key
        context.add(value: "B" as AnyObject, forKey: "b")
        let dict = context.toDict()
        XCTAssert(dict.count == 3, "Expected count 3, found \(dict.count)")
        XCTAssert(dict["a"] as! String == "1")
        XCTAssert(dict["b"] as! String == "B")
        XCTAssert(dict["c"] as! String == "3")
    }
}
