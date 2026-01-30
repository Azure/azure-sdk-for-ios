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

// swiftlint:disable force_try identifier_name

class TestPageableClient: PipelineClient, PageableClient {
    func continuationUrl(forRequestUrl requestUrl: URL, withContinuationToken token: String) -> URL? {
        return requestUrl.appendingQueryParameters(RequestParameters((.query, "marker", token, .encode)))
    }
}

class CollectionsTests: XCTestCase {
    func load(resource name: String, withExtension ext: String) -> Data {
        let testBundle = Bundle(for: type(of: self))
        let url = testBundle.url(forResource: name, withExtension: ext)
        return try! Data(contentsOf: url!)
    }

    class JsonTestItem: Codable {
        let id: Int
        let name: String
        let value: String?

        public init(id: Int, name: String, value: String?) {
            self.id = id
            self.name = name
            self.value = value
        }
    }

    /// Test that authors can simply use the default PagedCodingKeys if the service fits the Azure standard.
    func test_PagedCollection_WithDefaultCodingKeys_Inits() {
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

        // simulate data received
        let data = load(resource: "pagedthings1", withExtension: "json")
        let jsonObject = try! JSONSerialization.jsonObject(with: data)
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        let codingKeys = PagedCodingKeys()
        let paged = try! PagedCollection<JsonTestItem>(
            client: client,
            request: request,
            context: PipelineContext(),
            data: jsonData,
            codingKeys: codingKeys
        )
        // test basics
        XCTAssertEqual(paged.items!.count, 3)
        XCTAssertGreaterThanOrEqual(paged.underestimatedCount, 3)
        XCTAssertNil(paged.continuationToken)
        XCTAssertEqual(paged.pageItems?.count, 3)

        // test default continuationUrl
        let requestUrl = URL(string: "www.requestUrl.com")!
            .appendingQueryParameters(RequestParameters((.query, "ref", "123", .encode)))!
        let continuationUrl = client.continuationUrl(forRequestUrl: requestUrl, withContinuationToken: "testToken")!
        XCTAssertEqual(continuationUrl.absoluteString, "\(requestUrl.absoluteString)&marker=testToken")
    }

    /// Test that authors can customize the PagedCodingKeys provided they fit the standard structure.
    func test_PagedCollection_WithCustomCodingKeys_Inits() {
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

        // simulate data received
        let data = load(resource: "pagedthings2", withExtension: "json")
        let jsonObject = try! JSONSerialization.jsonObject(with: data)
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        let codingKeys = PagedCodingKeys(items: "stuff", continuationToken: "@nextPage")
        let paged = try! PagedCollection<JsonTestItem>(
            client: client,
            request: request,
            context: PipelineContext(),
            data: jsonData,
            codingKeys: codingKeys
        )
        XCTAssertEqual(paged.items!.count, 3)
        XCTAssertEqual(paged.continuationToken, "token")
    }

    func test_PagedCollection_CanIteratePerItem() {
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
        // simulate data received
        let data = load(resource: "pagedthings1", withExtension: "json")
        let jsonObject = try! JSONSerialization.jsonObject(with: data)
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        let codingKeys = PagedCodingKeys()
        let paged = try! PagedCollection<JsonTestItem>(
            client: client,
            request: request,
            context: PipelineContext(),
            data: jsonData,
            codingKeys: codingKeys
        )

        let newPageExpectation = expectation(description: "Attempt to retrieve new page.")
        let expectations = [
            expectation(description: "Item 1 retrieved."),
            expectation(description: "Item 2 retrieved."),
            expectation(description: "Item 3 retrieved."),
            newPageExpectation
        ]
        for index in 0 ..< 3 {
            paged.nextItem { result in
                switch result {
                case let .success(item):
                    XCTAssertEqual(item.id, index + 1)
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
                expectations[index].fulfill()
            }
        }

        // verify that fourth call to nextItem triggers a page fetch (which will fail)
        paged.nextItem { result in
            switch result {
            case .failure:
                break
            case .success:
                XCTFail("Did not fail.")
            }
            newPageExpectation.fulfill()
        }
        wait(for: expectations, timeout: 5)
    }

    @available(iOS 13.0.0, *)
    func test_PagedCollection_CanAsyncIteratePerItem() async throws {
        let client = TestPageableClient(
            endpoint: URL(string: "http://www.microsoft.com")!,
            transport: URLSessionTransport(),
            policies: [
                UserAgentPolicy(sdkName: "Test", sdkVersion: "1.0")
            ],
            logger: ClientLoggers.default(),
            options: TestClientOptions()
        )
        let request = try HTTPRequest(method: .get, url: "test")
        // simulate data received
        let data = load(resource: "pagedthings1", withExtension: "json")
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
        let codingKeys = PagedCodingKeys()
        let paged = try PagedCollection<JsonTestItem>(
            client: client,
            request: request,
            context: PipelineContext(),
            data: jsonData,
            codingKeys: codingKeys
        )

        for index in 0 ..< 3 {
            let item = try await paged.nextItem()
            XCTAssertEqual(item.id, index + 1)
        }

        // verify that fourth call to nextItem triggers a page fetch (which will fail)
        do {
            let noMore = try await paged.nextItem()
            XCTFail("Error should have been thrown")
        } catch {}
    }
}
