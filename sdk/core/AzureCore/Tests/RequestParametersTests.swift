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

// MARK: Test Object Defintions

enum AnimalEnum: String, RequestStringConvertible {
    case cat
    case dog

    var requestString: String {
        return rawValue
    }
}

enum FlavorEnum: Int, RequestStringConvertible {
    case chocolate
    case vanilla

    var requestString: String {
        return String(rawValue)
    }
}

enum ShapeEnum: RequestStringConvertible {
    case custom(String)
    case square
    case circle

    var requestString: String {
        switch self {
        case let .custom(val):
            return val
        case .square:
            return "square"
        case .circle:
            return "circle"
        }
    }
}

// MARK: Test Cases

class QueryParametersTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_QueryParameters_WithOptionals() throws {
        let nilString: String? = nil
        let query = RequestParameters(
            (.query, "var1", "test", .encode),
            (.query, "var2", nilString, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "test")
    }

    func test_QueryParameters_WithInt() throws {
        let query = RequestParameters(
            (.query, "var1", 5, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "5")
    }

    func test_QueryParameters_WithInt32() throws {
        let val: Int32 = 5
        let query = RequestParameters(
            (.query, "var1", val, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "5")
    }

    func test_QueryParameters_WithInt64() throws {
        let val: Int64 = 5
        let query = RequestParameters(
            (.query, "var1", val, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "5")
    }

    func test_QueryParameters_WithFloat() throws {
        let val: Float = 5.0
        let query = RequestParameters(
            (.query, "var1", val, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "5.0")
    }

    func test_QueryParameters_WithDouble() throws {
        let val = 5.0
        let query = RequestParameters(
            (.query, "var1", val, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "5.0")
    }

    func test_QueryParameters_WithBool() throws {
        let query = RequestParameters(
            (.query, "var1", true, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "true")
    }

    func test_QueryParameters_WithDate() throws {
        let date = SimpleDate(string: "2000-01-01")
        let query = RequestParameters(
            (.query, "var1", date, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "2000-01-01")
    }

    func test_QueryParameters_WithData() throws {
        let data = "test".data(using: .utf8)
        let query = RequestParameters(
            (.query, "var1", data, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "test")
    }

    func test_QueryParameters_WithStringBackedEnum() throws {
        let query = RequestParameters(
            (.query, "var1", AnimalEnum.cat, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "cat")
    }

    func test_QueryParameters_WithExtensibleStringBackedEnum() throws {
        let query = RequestParameters(
            (.query, "var1", ShapeEnum.custom("parallelogram"), .encode),
            (.query, "var2", ShapeEnum.circle, .encode)
        )
        XCTAssert(query.parameters.count == 2)
        XCTAssert(query.parameters[0].value == "parallelogram")
        XCTAssert(query.parameters[1].value == "circle")
    }

    func test_QueryParameters_WithIntBackedEnum() throws {
        let query = RequestParameters(
            (.query, "var1", FlavorEnum.chocolate, .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "0")
    }

    func test_QueryParameters_WithOptionalStringArray() throws {
        let query = RequestParameters(
            (.query, "var1", ["test", nil, "begin!*'();:@ &=+$,/?#[]end"], .encode)
        )
        XCTAssert(query.parameters.count == 1)
        XCTAssert(query.parameters[0].value == "test,,begin!*'();:@ &=+$,/?#[]end")
    }
}
