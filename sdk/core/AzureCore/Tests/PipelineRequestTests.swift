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

// swiftlint:disable force_try
class PipelineRequestTests: XCTestCase {
    func test_PipelineContext_CanAddAndAccessValues() {
        let logger = ClientLoggers.default()
        let httpRequest = try! HTTPRequest(method: .get, url: "https://www.contoso.com")
        var pipelineRequest = PipelineRequest(request: httpRequest, logger: logger)

        // add context when one did not exist
        pipelineRequest.add(value: "Value" as AnyObject, forKey: "Test")

        // retrieve value from context by string key
        var result = pipelineRequest.value(forKey: "Test") as? String
        XCTAssertEqual(result, "Value")

        // retrieve value from context by enum key
        pipelineRequest.add(value: "TestValue" as AnyObject, forKey: .xmlMap)
        result = pipelineRequest.value(forKey: .xmlMap) as? String
        XCTAssertEqual(result, "TestValue")

        // does not crash when item not present
        XCTAssertNil(pipelineRequest.value(forKey: .deserializedData))

        // verify the static initializer works
        let newContext = PipelineContext.of(keyValues: [
            "a": "1" as AnyObject,
            "b": "2" as AnyObject
        ])
        XCTAssertEqual(newContext.count, 2)
    }
}
