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

protocol Thing {
    var attr: String { get }
    var reqString: String { get }
    var optString: String? { get }
    var reqDouble: Double { get }
    var optDouble: Double? { get }
    var reqInt: Int { get }
    var optInt: Int? { get }
    var reqBool: Bool { get }
    var optBool: Bool? { get }
}

// MARK: InferredThing

final class InferredThing: Thing {
    let attr: String
    let reqString: String
    let optString: String?
    let reqDouble: Double
    let optDouble: Double?
    let reqInt: Int
    let optInt: Int?
    let reqBool: Bool
    let optBool: Bool?

    init(
        attr: String,
        reqString: String,
        reqDouble: Double,
        reqInt: Int,
        reqBool: Bool,
        optString: String?,
        optDouble: Double?,
        optInt: Int?,
        optBool: Bool?
    ) {
        self.attr = attr
        self.reqString = reqString
        self.optString = optString
        self.reqDouble = reqDouble
        self.optDouble = optDouble
        self.reqInt = reqInt
        self.optInt = optInt
        self.reqBool = reqBool
        self.optBool = optBool
    }
}

extension InferredThing: Codable {
    enum CodingKeys: String, CodingKey {
        case attr = "_id"
        case reqString = "req_string"
        case optString
        case reqDouble
        case optDouble
        case reqInt
        case optInt
        case reqBool
        case optBool = "opt_bool"
    }

    convenience init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            attr: root.decode(String.self, forKey: .attr),
            reqString: root.decode(String.self, forKey: .reqString),
            reqDouble: root.decodeDouble(forKey: .reqDouble),
            reqInt: root.decodeInt(forKey: .reqInt),
            reqBool: root.decodeBool(forKey: .reqBool),
            optString: root.decodeIfPresent(String.self, forKey: .optString),
            optDouble: root.decodeDoubleIfPresent(forKey: .optDouble),
            optInt: root.decodeIntIfPresent(forKey: .optInt),
            optBool: root.decodeBoolIfPresent(forKey: .optBool)
        )
    }
}

// MARK: MappedThing

final class MappedThing: Thing, XMLModel {
    let attr: String
    let reqString: String
    let optString: String?
    let reqDouble: Double
    let optDouble: Double?
    let reqInt: Int
    let optInt: Int?
    let reqBool: Bool
    let optBool: Bool?

    init(
        attr: String,
        reqString: String,
        reqDouble: Double,
        reqInt: Int,
        reqBool: Bool,
        optString: String?,
        optDouble: Double?,
        optInt: Int?,
        optBool: Bool?
    ) {
        self.attr = attr
        self.reqString = reqString
        self.optString = optString
        self.reqDouble = reqDouble
        self.optDouble = optDouble
        self.reqInt = reqInt
        self.optInt = optInt
        self.reqBool = reqBool
        self.optBool = optBool
    }

    static func xmlMap() -> XMLMap {
        return XMLMap([
            "item": XMLMetadata(jsonName: "", jsonType: .flatten, attributes: .underscoredProperties),
            "_id": XMLMetadata(jsonName: "attr"),
            "req_string": XMLMetadata(jsonName: "reqString"),
            "optString": XMLMetadata(jsonName: "optString"),
            "reqDouble": XMLMetadata(jsonName: "reqDouble"),
            "optDouble": XMLMetadata(jsonName: "optDouble"),
            "reqInt": XMLMetadata(jsonName: "reqInt"),
            "optInt": XMLMetadata(jsonName: "optInt"),
            "reqBool": XMLMetadata(jsonName: "reqBool"),
            "opt_bool": XMLMetadata(jsonName: "optBool")
        ])
    }
}

extension MappedThing: Codable {
    enum CodingKeys: String, CodingKey {
        case attr, reqString, optString, reqDouble, optDouble, reqInt, optInt, reqBool, optBool
    }

    convenience init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            attr: root.decode(String.self, forKey: .attr),
            reqString: root.decode(String.self, forKey: .reqString),
            reqDouble: root.decodeDouble(forKey: .reqDouble),
            reqInt: root.decodeInt(forKey: .reqInt),
            reqBool: root.decodeBool(forKey: .reqBool),
            optString: root.decodeIfPresent(String.self, forKey: .optString),
            optDouble: root.decodeDoubleIfPresent(forKey: .optDouble),
            optInt: root.decodeIntIfPresent(forKey: .optInt),
            optBool: root.decodeBoolIfPresent(forKey: .optBool)
        )
    }
}

// MARK: PagedThing

final class PagedThing: Codable, XMLModel {
    let id: Int
    let name: String
    let value: String?

    init(id: Int, name: String, value: String?) {
        self.id = id
        self.name = name
        self.value = value
    }

    convenience init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: root.decodeInt(forKey: .id),
            name: root.decode(String.self, forKey: .name),
            value: root.decodeIfPresent(String.self, forKey: .value)
        )
    }

    static func xmlMap() -> XMLMap {
        return XMLMap([
            "id": XMLMetadata(jsonName: "id"),
            "name": XMLMetadata(jsonName: "name"),
            "value": XMLMetadata(jsonName: "value")
        ])
    }
}

// MARK: - Test Methods

class XMLModelTests: XCTestCase {
    func load(resource name: String, withExtension ext: String) -> Data {
        let testBundle = Bundle(for: type(of: self))
        let url = testBundle.url(forResource: name, withExtension: ext)
        return try! Data(contentsOf: url!)
    }

    func assertThing(_ thing: Thing, withName name: String) {
        XCTAssertEqual(thing.attr, "id100")
        XCTAssertEqual(thing.reqString, "Test")
        XCTAssertEqual(thing.reqDouble, 10.99)
        XCTAssertEqual(thing.reqInt, 21)
        XCTAssertEqual(thing.reqBool, true)
        if name == "thing1" {
            XCTAssertEqual(thing.optString, "Optional")
            XCTAssertEqual(thing.optDouble, 12.34)
            XCTAssertEqual(thing.optInt, 34)
            XCTAssertEqual(thing.optBool, true)
        } else if name == "thing2" {
            XCTAssertNil(thing.optString)
            XCTAssertNil(thing.optDouble)
            XCTAssertNil(thing.optInt)
            XCTAssertNil(thing.optBool)
        }
    }

    /// Test that an XML Model can be inferred from an object structure.
    func test_XMLModel_WithoutXMLMap_CanBeCreated() {
        for name in ["thing1", "thing2"] {
            let decodePolicy = ContentDecodePolicy()

            let xmlData = load(resource: name, withExtension: "xml")
            let jsonObject = try! decodePolicy.parse(xml: xmlData)
            // since the top-level tags are treated as "AnyObject", we must extract the data to create the
            // strongly-typed object
            let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject["item"] as Any)
            let thing = try! JSONDecoder().decode(InferredThing.self, from: jsonData)
            assertThing(thing, withName: name)
        }
    }

    /// Test that an XML Model can be created with a custom XML map.
    func test_XMLModel_WithXMLMap_CanBeCreated() {
        for name in ["thing1", "thing2"] {
            let decodePolicy = ContentDecodePolicy()
            decodePolicy.xmlParser.xmlMap = MappedThing.xmlMap()

            let xmlData = load(resource: name, withExtension: "xml")
            let jsonObject = try! decodePolicy.parse(xml: xmlData)
            // since the top-level tags are treated as "AnyObject", we must extract the data to create the
            // strongly-typed object
            let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
            let thing = try! JSONDecoder().decode(MappedThing.self, from: jsonData)
            assertThing(thing, withName: name)
        }
    }

    /// Test that an XML Model can be constructed that works with the PagedCollection type.
    func test_XMLModel_WithPagedCollectionAndXMLMap_CanBeCreated() {
        let client = TestPageableClient(
            endpoint: URL(string: "http://www.microsoft.com")!,
            transport: URLSessionTransport(),
            policies: [
                UserAgentPolicy(sdkName: "Test", sdkVersion: "1.0")
            ],
            logger: ClientLoggers.default(),
            options: TestClientOptions()
        )
        let request = try! HTTPRequest(method: .get, url: "test")

        let decodePolicy = ContentDecodePolicy()
        let pagedKeys = PagedCodingKeys(items: "things.items", continuationToken: "things.next", xmlItemName: "item")
        decodePolicy.xmlParser.xmlMap = XMLMap(withPagedCodingKeys: pagedKeys, innerType: PagedThing.self)

        let xmlData = load(resource: "pagedthings", withExtension: "xml")
        let jsonObject = try! decodePolicy.parse(xml: xmlData)
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        let paged = try! PagedCollection<PagedThing>(
            client: client,
            request: request,
            context: PipelineContext(),
            data: jsonData,
            codingKeys: pagedKeys
        )
        XCTAssertGreaterThanOrEqual(paged.underestimatedCount, 3)
    }
}
