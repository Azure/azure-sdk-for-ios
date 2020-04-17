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

class CryptoUtilTests: XCTestCase {
    // MARK: Data.hash

    /// Test that Data.hash calculates SHA1 correctly
    func test_Data_HashSHA1IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let hash = data.hash(algorithm: .sha1)

        XCTAssertEqual(
            hash.hexadecimalString(),
            "7b502c3a1f48c8609ae212cdfb639dee39673f5e"
        )
    }

    /// Test that Data.hash calculates MD5 correctly
    func test_Data_HashMD5IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let hash = data.hash(algorithm: .md5)

        XCTAssertEqual(
            hash.hexadecimalString(),
            "3e25960a79dbc69b674cd4ec67a72c62"
        )
    }

    /// Test that Data.hash calculates SHA256 correctly
    func test_Data_HashSHA256IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let hash = data.hash(algorithm: .sha256)

        XCTAssertEqual(
            hash.hexadecimalString(),
            "64ec88ca00b268e5ba1a35678a1b5316d212f4f366b2477232534a8aeca37f3c"
        )
    }

    /// Test that Data.hash calculates SHA384 correctly
    func test_Data_HashSHA384IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let hash = data.hash(algorithm: .sha384)

        XCTAssertEqual(
            hash.hexadecimalString(),
            "9203b0c4439fd1e6ae5878866337b7c532acd6d9260150c80318e8ab8c27ce330189f8df94fb890df1d298ff360627e1"
        )
    }

    /// Test that Data.hash calculates SHA512 correctly
    func test_Data_HashSHA512IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let hash = data.hash(algorithm: .sha512)

        XCTAssertEqual(
            hash.hexadecimalString(),
            """
            b7f783baed8297f0db917462184ff4f08e69c2d5e5f79a942600f9725f58ce1f29c18139bf80b06c0fff2bdd34738452ecf40c488c2\
            2a7e3d80cdf6f9c1c0d47
            """
        )
    }

    /// Test that Data.hash calculates SHA224 correctly
    func test_Data_HashSHA224IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let hash = data.hash(algorithm: .sha224)

        XCTAssertEqual(
            hash.hexadecimalString(),
            "ac230f15fcae7f77d8f76e99adf45864a1c6f800655da78dea956112"
        )
    }

    // MARK: Data.hmac

    /// Test that Data.hmac calculates HMAC-SHA1 correctly
    func test_Data_HMACSHA1IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let key = "secret".data(using: .utf8)!
        let hmac = data.hmac(algorithm: .sha1, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            "08d79828e89d154e74addf8bfcb647e7770bfe9a"
        )
    }

    /// Test that Data.hmac calculates HMAC-MD5 correctly
    func test_Data_HMACMD5IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let key = "secret".data(using: .utf8)!
        let hmac = data.hmac(algorithm: .md5, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            "3fd162f1e3fa761d6e618ea6c1a19efb"
        )
    }

    /// Test that Data.hmac calculates HMAC-SHA256 correctly
    func test_Data_HMACSHA256IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let key = "secret".data(using: .utf8)!
        let hmac = data.hmac(algorithm: .sha256, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            "0d5548fb7450e619b0753725068707519ed41cd212b0500bc20427e3ef66e08e"
        )
    }

    /// Test that Data.hmac calculates HMAC-SHA384 correctly
    func test_Data_HMACSHA384IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let key = "secret".data(using: .utf8)!
        let hmac = data.hmac(algorithm: .sha384, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            "0c58c9c6e03e75122d28616e6d9f2b23313df47ae6c644a4042e286ba5db6f8e742e06b240cea591c5e30f319850e811"
        )
    }

    /// Test that Data.hmac calculates HMAC-SHA512 correctly
    func test_Data_HMACSHA512IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let key = "secret".data(using: .utf8)!
        let hmac = data.hmac(algorithm: .sha512, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            """
            10e1839d61c3ecf89f72acfe37193d3a94567eb30c911a4ab6d199ed942f65000d5a0be83e34d9ef06ba3dc005137d9f564dfbda5b8\
            723abde909913a1ff5a77
            """
        )
    }

    /// Test that Data.hmac calculates HMAC-SHA224 correctly
    func test_Data_HMACSHA224IsCorrect() {
        let data = "Hello world".data(using: .utf8)!
        let key = "secret".data(using: .utf8)!
        let hmac = data.hmac(algorithm: .sha224, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            "fc84bcdd67af9de1502b5962eaa5a9204078de8d97ae208531014e79"
        )
    }

    // MARK: String.hash

    /// Test that String.hash calculates SHA1 correctly
    func test_String_HashSHA1IsCorrect() {
        let string = "Hello world"
        let hash = string.hash(algorithm: .sha1)

        XCTAssertEqual(
            hash.hexadecimalString(),
            "7b502c3a1f48c8609ae212cdfb639dee39673f5e"
        )
    }

    /// Test that String.hash calculates MD5 correctly
    func test_String_HashMD5IsCorrect() {
        let string = "Hello world"
        let hash = string.hash(algorithm: .md5)

        XCTAssertEqual(
            hash.hexadecimalString(),
            "3e25960a79dbc69b674cd4ec67a72c62"
        )
    }

    /// Test that String.hash calculates SHA256 correctly
    func test_String_HashSHA256IsCorrect() {
        let string = "Hello world"
        let hash = string.hash(algorithm: .sha256)

        XCTAssertEqual(
            hash.hexadecimalString(),
            "64ec88ca00b268e5ba1a35678a1b5316d212f4f366b2477232534a8aeca37f3c"
        )
    }

    /// Test that String.hash calculates SHA384 correctly
    func test_String_HashSHA384IsCorrect() {
        let string = "Hello world"
        let hash = string.hash(algorithm: .sha384)

        XCTAssertEqual(
            hash.hexadecimalString(),
            "9203b0c4439fd1e6ae5878866337b7c532acd6d9260150c80318e8ab8c27ce330189f8df94fb890df1d298ff360627e1"
        )
    }

    /// Test that String.hash calculates SHA512 correctly
    func test_String_HashSHA512IsCorrect() {
        let string = "Hello world"
        let hash = string.hash(algorithm: .sha512)

        XCTAssertEqual(
            hash.hexadecimalString(),
            """
            b7f783baed8297f0db917462184ff4f08e69c2d5e5f79a942600f9725f58ce1f29c18139bf80b06c0fff2bdd34738452ecf40c488c2\
            2a7e3d80cdf6f9c1c0d47
            """
        )
    }

    /// Test that String.hash calculates SHA224 correctly
    func test_String_HashSHA224IsCorrect() {
        let string = "Hello world"
        let hash = string.hash(algorithm: .sha224)

        XCTAssertEqual(
            hash.hexadecimalString(),
            "ac230f15fcae7f77d8f76e99adf45864a1c6f800655da78dea956112"
        )
    }

    // MARK: String.hmac

    /// Test that String.hmac calculates HMAC-SHA1 correctly
    func test_String_HMACSHA1IsCorrect() {
        let string = "Hello world"
        let key = "secret".data(using: .utf8)!
        let hmac = string.hmac(algorithm: .sha1, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            "08d79828e89d154e74addf8bfcb647e7770bfe9a"
        )
    }

    /// Test that String.hmac calculates HMAC-MD5 correctly
    func test_String_HMACMD5IsCorrect() {
        let string = "Hello world"
        let key = "secret".data(using: .utf8)!
        let hmac = string.hmac(algorithm: .md5, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            "3fd162f1e3fa761d6e618ea6c1a19efb"
        )
    }

    /// Test that String.hmac calculates HMAC-SHA256 correctly
    func test_String_HMACSHA256IsCorrect() {
        let string = "Hello world"
        let key = "secret".data(using: .utf8)!
        let hmac = string.hmac(algorithm: .sha256, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            "0d5548fb7450e619b0753725068707519ed41cd212b0500bc20427e3ef66e08e"
        )
    }

    /// Test that String.hmac calculates HMAC-SHA384 correctly
    func test_String_HMACSHA384IsCorrect() {
        let string = "Hello world"
        let key = "secret".data(using: .utf8)!
        let hmac = string.hmac(algorithm: .sha384, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            "0c58c9c6e03e75122d28616e6d9f2b23313df47ae6c644a4042e286ba5db6f8e742e06b240cea591c5e30f319850e811"
        )
    }

    /// Test that String.hmac calculates HMAC-SHA512 correctly
    func test_String_HMACSHA512IsCorrect() {
        let string = "Hello world"
        let key = "secret".data(using: .utf8)!
        let hmac = string.hmac(algorithm: .sha512, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            """
            10e1839d61c3ecf89f72acfe37193d3a94567eb30c911a4ab6d199ed942f65000d5a0be83e34d9ef06ba3dc005137d9f564dfbda5b8\
            723abde909913a1ff5a77
            """
        )
    }

    /// Test that String.hmac calculates HMAC-SHA224 correctly
    func test_String_HMACSHA224IsCorrect() {
        let string = "Hello world"
        let key = "secret".data(using: .utf8)!
        let hmac = string.hmac(algorithm: .sha224, key: key)

        XCTAssertEqual(
            hmac.hexadecimalString(),
            "fc84bcdd67af9de1502b5962eaa5a9204078de8d97ae208531014e79"
        )
    }
}
