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
@testable import AzureStorageBlob
import XCTest

// swiftlint:disable force_try file_length type_body_length line_length type_name
class StorageSharedKeyAuthenticationPolicyTests: XCTestCase {
    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithSimpleURL_IsCorrect() {
        let stringToSign = """
        GET





        Thu, 16 Apr 2020 00:00:00 GMT





        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-version:2019-02-02
        /sampleaccount/samplecontainer/sampleblob
        a:foo
        b:bar
        c:baz
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://\(accountName).blob.core.windows.net/samplecontainer/sampleblob?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithURLContainingEncodedChars_IsCorrect() {
        let stringToSign = """
        GET





        Thu, 16 Apr 2020 00:00:00 GMT





        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-version:2019-02-02
        /sampleaccount/samplecontainer/sample%20blob%20123
        a:foo
        b:bar
        c:baz
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://\(accountName).blob.core.windows.net/samplecontainer/sample blob 123?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithURLHavingNoPath_IsCorrect() {
        let stringToSign = """
        GET





        Thu, 16 Apr 2020 00:00:00 GMT





        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-version:2019-02-02
        /sampleaccount/
        a:foo
        b:bar
        c:baz
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://\(accountName).blob.core.windows.net?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithOnlyXmsDate_IsCorrect() {
        let stringToSign = """
        GET











        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-date:Thu, 16 Apr 2020 00:00:00 GMT
        x-ms-version:2019-02-02
        /sampleaccount/
        a:foo
        b:bar
        c:baz
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .xmsDate: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://\(accountName).blob.core.windows.net?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithDateAndXmsDate_IsCorrect() {
        let stringToSign = """
        GET











        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-date:Thu, 16 Apr 2020 00:00:00 GMT
        x-ms-version:2019-02-02
        /sampleaccount/
        a:foo
        b:bar
        c:baz
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 12:12:12 GMT",
            .xmsDate: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://\(accountName).blob.core.windows.net?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithContentLength_IsCorrect() {
        let stringToSign = """
        PUT


        123


        Thu, 16 Apr 2020 00:00:00 GMT





        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-version:2019-02-02
        /sampleaccount/samplecontainer/sampleblob
        a:foo
        b:bar
        c:baz
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff",
            .contentLength: "123"
        ])
        let httpRequest = try! HTTPRequest(
            method: .put,
            url: "https://\(accountName).blob.core.windows.net/samplecontainer/sampleblob?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithZeroContentLength_IsCorrect() {
        let stringToSign = """
        PUT





        Thu, 16 Apr 2020 00:00:00 GMT





        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-version:2019-02-02
        /sampleaccount/samplecontainer/sampleblob
        a:foo
        b:bar
        c:baz
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff",
            .contentLength: "0"
        ])
        let httpRequest = try! HTTPRequest(
            method: .put,
            url: "https://\(accountName).blob.core.windows.net/samplecontainer/sampleblob?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithCanonicalizedHeadersContainingLeadingSpaces_IsCorrect(
    ) {
        let stringToSign = """
        GET





        Thu, 16 Apr 2020 00:00:00 GMT





        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-version:2019-02-02
        /sampleaccount/samplecontainer/sampleblob
        a:foo
        b:bar
        c:baz
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://\(accountName).blob.core.windows.net/samplecontainer/sampleblob?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithCanonicalizedHeadersAndQueryParamNamesContainingUppercase_IsCorrect(
    ) {
        let stringToSign = """
        GET





        Thu, 16 Apr 2020 00:00:00 GMT





        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-copy-status:foobar
        x-ms-version:2019-02-02
        /sampleaccount/samplecontainer/sampleblob
        a:foo
        b:bar
        c:baz
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        var headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        headers["X-MS-Copy-Status"] = "foobar"
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://\(accountName).blob.core.windows.net/samplecontainer/sampleblob?C=baz&b=bar&A=foo",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithAccountNameInURLNotMatchingCredential_IsCorrect() {
        let stringToSign = """
        GET





        Thu, 16 Apr 2020 00:00:00 GMT





        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-version:2019-02-02
        /otheraccount/samplecontainer/sampleblob
        a:foo
        b:bar
        c:baz
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://otheraccount.blob.core.windows.net/samplecontainer/sampleblob?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_StringToSign_WithEncodedQueryStringParams_IsCorrect() {
        let stringToSign = """
        GET





        Thu, 16 Apr 2020 00:00:00 GMT





        x-ms-client-request-id:00112233-4455-6677-8899-aabbccddeeff
        x-ms-version:2019-02-02
        /sampleaccount/samplecontainer/sampleblob
        b:bar
        c:baz
        hello world:sample value
        """

        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://\(accountName).blob.core.windows.net/samplecontainer/sampleblob?hello%20world=sample%20value&b=bar&c=baz",
            headers: headers,
            data: nil
        )
        let calculatedString = try? policy.stringToSign(forRequest: httpRequest)
        XCTAssertEqual(calculatedString, stringToSign)
    }

    func test_StorageSharedKeyAuthenticationPolicy_AuthorizationHeader_WithSimpleURL_IsCorrect() {
        let header = "SharedKey sampleaccount:iCEpAbPT9EwH6KBW5Ki25WLQtxiFOv879HOkGTLy+uo="
        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://\(accountName).blob.core.windows.net/samplecontainer/sampleblob?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )

        let req = PipelineRequest(request: httpRequest, logger: ClientLoggers.none)
        policy.on(request: req) { _, _ in }
        let value = req.httpRequest.headers[.authorization]
        XCTAssertEqual(value, header)
    }

    func test_StorageSharedKeyAuthenticationPolicy_AuthorizationHeader_WithAccountNameInURLNotMatchingCredential_IsCorrect(
    ) {
        let header = "SharedKey sampleaccount:uuFTijPHK46ctAbZ8q/6wLeoDE2o3kl7y1g6VkVptIU="
        let accountName = "sampleaccount"
        let accessKey = "aGVsbG8gd29ybGQ=" // "hello world"
        let credential = StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
        let policy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        let headers = HTTPHeaders([
            .transferEncoding: "chunked",
            .userAgent: "foobar",
            .apiVersion: "2019-02-02",
            .date: "Thu, 16 Apr 2020 00:00:00 GMT",
            .accept: "application/xml",
            .clientRequestId: "00112233-4455-6677-8899-aabbccddeeff"
        ])
        let httpRequest = try! HTTPRequest(
            method: .get,
            url: "https://otheraccount.blob.core.windows.net/samplecontainer/sampleblob?a=foo&b=bar&c=baz",
            headers: headers,
            data: nil
        )

        let req = PipelineRequest(request: httpRequest, logger: ClientLoggers.none)
        policy.on(request: req) { _, _ in }
        let value = req.httpRequest.headers[.authorization]
        XCTAssertEqual(value, header)
    }
}
