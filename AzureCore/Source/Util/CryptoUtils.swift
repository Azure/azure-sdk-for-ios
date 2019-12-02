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

import CommonCrypto
import Foundation

// MARK: Enumerations

/// Crypto HMAC algorithms and digest lengths
public enum CryptoAlgorithm {
    case sha1, md5, sha256, sha384, sha512, sha224

    /// Underlying CommonCrypto HMAC algorithm.
    public var hmacAlgorithm: CCHmacAlgorithm {
        var alg = 0
        switch self {
        case .sha1:
            alg = kCCHmacAlgSHA1
        case .md5:
            alg = kCCHmacAlgMD5
        case .sha256:
            alg = kCCHmacAlgSHA256
        case .sha384:
            alg = kCCHmacAlgSHA384
        case .sha512:
            alg = kCCHmacAlgSHA512
        case .sha224:
            alg = kCCHmacAlgSHA224
        }
        return CCHmacAlgorithm(alg)
    }

    /// Compute a hash of the underlying data using the specfied algorithm.
    public func hash(_ data: UnsafeRawPointer!, _ len: CC_LONG, _ message: UnsafeMutablePointer<UInt8>!) -> Data {
        var result: UnsafeMutablePointer<UInt8>?
        switch self {
        case .md5:
            result = CC_MD5(data, len, message)
        case .sha1:
            result = CC_SHA1(data, len, message)
        case .sha224:
            result = CC_SHA224(data, len, message)
        case .sha256:
            result = CC_SHA224(data, len, message)
        case .sha384:
            result = CC_SHA384(data, len, message)
        case .sha512:
            result = CC_SHA512(data, len, message)
        }
        return Data(bytes: result!, count: Int(len))
    }

    /// Digest length for the HMAC algorithm.
    public var digestLength: Int {
        var len: Int32 = 0
        switch self {
        case .sha1:
            len = CC_SHA1_DIGEST_LENGTH
        case .md5:
            len = CC_MD5_DIGEST_LENGTH
        case .sha256:
            len = CC_SHA256_DIGEST_LENGTH
        case .sha384:
            len = CC_SHA384_DIGEST_LENGTH
        case .sha512:
            len = CC_SHA512_DIGEST_LENGTH
        case .sha224:
            len = CC_SHA224_DIGEST_LENGTH
        }
        return Int(len)
    }
}

// MARK: Extension - String

extension String {

    /**
     Calculate the HMAC digest of a string.
     - Parameter algorithm: The cryptographic algorithm to use.
     - Parameter key: The key used to compute the HMAC, in `Data` format.
     - Returns: The HMAC digest in `Data` format.
     */
    public func hmac(algorithm: CryptoAlgorithm, key: Data) throws -> Data {
        let error = AzureError.general("Unable to compute HMAC.")
        let strBytes = self.cString(using: .utf8)
        let strLen = Int(self.lengthOfBytes(using: .utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLen)
        defer { result.deallocate() }
        _ = key.withUnsafeBytes { keyBytes in
            CCHmac(algorithm.hmacAlgorithm, keyBytes, key.count, strBytes, strLen, result)
        }
        let digest = Data(bytes: result, count: digestLen)
        return digest
    }

    /**
     Compute the hash function of a string.
     - Parameter algorithm: The cryptographic algorithm to use.
     - Returns: The hash digest in `Data` format. This can then be converted to a base64 or hex string using the
        `base64String` or `hexString` extension methods.
     */
    public func hash(algorithm: CryptoAlgorithm) throws -> Data {
        let error = AzureError.general("Unable to compute hash.")
        guard let dataToHash = self.data(using: .utf8) else { throw error }
        return try dataToHash.hash(algorithm: algorithm)
    }

    /// Returns the base64 representation of a string.
    public var base64String: String {
        let data = Data(bytes: self, count: count)
        return data.base64EncodedString()
    }

    /// Returns the decoded `Data` of a hex string, or nil.
    public var decodeHex: Data? {
        var data = Data(capacity: count / 2)

        if let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) {
            regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
                let byteString = (self as NSString).substring(with: match!.range)
                let num = UInt8(byteString, radix: 16)!
                data.append(num)
            }
        }
        guard data.count > 0 else { return nil }
        return data
    }

    /// Returns the decoded `Data` of a base64-encoded string, or nil.
    public var decodeBase64: Data? {
        return Data(base64Encoded: self)
    }
}

// MARK: Extension - Data

extension Data {

    /**
     Calculate the HMAC digest of data.
     - Parameter algorithm: The HMAC algorithm to use.
     - Parameter key: The key used to compute the HMAC, in `Data` format.
     - Returns: The HMAC digest in `Data` format.
     */
    public func hmac(algorithm: CryptoAlgorithm, key: Data) throws -> Data {
        let error = AzureError.general("Unable to compute HMAC.")
        guard let dataString = String(data: self, encoding: .utf8) else { throw error }
        return try dataString.hmac(algorithm: algorithm, key: key)
    }

    /**
     Compute the hash function of a string.
     - Parameter algorithm: The cryptographic algorithm to use.
     - Returns: The hash digest in `Data` format. This can then be converted to a base64 or hex string using the `base64String` or `hexString`
                extension methods.
     */
    public func hash(algorithm: CryptoAlgorithm) throws -> Data {
        var digest = Data(count: Int(algorithm.digestLength))
        _ = digest.withUnsafeMutableBytes { digestBytes in
            self.withUnsafeBytes { messageBytes in
                algorithm.hash(messageBytes, CC_LONG(self.count), digestBytes)
            }
        }
        return digest
    }

    /// Returns the base64-encoded string representation of a `Data` object.
    public var base64String: String {
        return self.base64EncodedString()
    }

    /// Returns the hex string representation of a `Data` object.
    public var hexString: String {
        return compactMap { String(format: "%02x", $0) }.joined().uppercased()
    }
}
