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

#if canImport(CommonCrypto)
import CommonCrypto
#endif
import Foundation

// MARK: Enumerations

/// Crypto HMAC algorithms and digest lengths
public enum CryptoAlgorithm {
    case sha1, md5, sha256, sha384, sha512, sha224

    /// Underlying CommonCrypto HMAC algorithm.
    public var hmacAlgorithm: CCHmacAlgorithm {
        switch self {
        case .sha1:
            return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .md5:
            return CCHmacAlgorithm(kCCHmacAlgMD5)
        case .sha256:
            return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .sha384:
            return CCHmacAlgorithm(kCCHmacAlgSHA384)
        case .sha512:
            return CCHmacAlgorithm(kCCHmacAlgSHA512)
        case .sha224:
            return CCHmacAlgorithm(kCCHmacAlgSHA224)
        }
    }

    /// Digest length for the HMAC algorithm.
    public var digestLength: Int {
        switch self {
        case .sha1:
            return Int(CC_SHA1_DIGEST_LENGTH)
        case .md5:
            return Int(CC_MD5_DIGEST_LENGTH)
        case .sha256:
            return Int(CC_SHA256_DIGEST_LENGTH)
        case .sha384:
            return Int(CC_SHA384_DIGEST_LENGTH)
        case .sha512:
            return Int(CC_SHA512_DIGEST_LENGTH)
        case .sha224:
            return Int(CC_SHA224_DIGEST_LENGTH)
        }
    }

    /// Calculate the HMAC digest of data.
    public func hmac(_ data: UnsafeRawPointer!, dataLength: Int, withKey key: Data) -> Data {
        let digestLen = digestLength
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLen)
        defer { result.deallocate() }

        key.withUnsafeBytes { keyBytes in
            CCHmac(self.hmacAlgorithm, keyBytes.baseAddress, key.count, data, dataLength, result)
        }

        return Data(bytes: result, count: digestLen)
    }

    /// Compute a hash of the underlying data using the specfied algorithm.
    public func hash(_ data: UnsafeRawPointer!, dataLength: Int) -> Data {
        let digestLen = digestLength
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLen)
        defer { result.deallocate() }

        switch self {
        case .md5:
            CC_MD5(data, CC_LONG(dataLength), result)
        case .sha1:
            CC_SHA1(data, CC_LONG(dataLength), result)
        case .sha224:
            CC_SHA224(data, CC_LONG(dataLength), result)
        case .sha256:
            CC_SHA256(data, CC_LONG(dataLength), result)
        case .sha384:
            CC_SHA384(data, CC_LONG(dataLength), result)
        case .sha512:
            CC_SHA512(data, CC_LONG(dataLength), result)
        }

        return Data(bytes: result, count: digestLen)
    }
}

// MARK: Extension - String

public extension String {
    /**
     Calculate the HMAC digest of a string.
     - Parameter algorithm: The cryptographic algorithm to use.
     - Parameter key: The key used to compute the HMAC, in `Data` format.
     - Returns: The HMAC digest in `Data` format.
     */
    func hmac(algorithm: CryptoAlgorithm, key: Data) -> Data {
        let strBytes = cString(using: .utf8)
        let strLen = Int(lengthOfBytes(using: .utf8))
        return algorithm.hmac(strBytes, dataLength: strLen, withKey: key)
    }

    /**
     Compute the hash function of a string.
     - Parameter algorithm: The cryptographic algorithm to use.
     - Returns: The hash digest in `Data` format. This can then be converted to a base64 or hex string using the
        `base64String` or `hexString` extension methods.
     */
    func hash(algorithm: CryptoAlgorithm) -> Data {
        let strBytes = cString(using: .utf8)
        let strLen = Int(lengthOfBytes(using: .utf8))
        return algorithm.hash(strBytes, dataLength: strLen)
    }
}

// MARK: Extension - Data

public extension Data {
    /**
     Calculate the HMAC digest of data.
     - Parameter algorithm: The HMAC algorithm to use.
     - Parameter key: The key used to compute the HMAC, in `Data` format.
     - Returns: The HMAC digest in `Data` format.
     */
    func hmac(algorithm: CryptoAlgorithm, key: Data) -> Data {
        return withUnsafeBytes { dataBytes in
            algorithm.hmac(dataBytes.baseAddress, dataLength: self.count, withKey: key)
        }
    }

    /**
     Compute the hash function of a string.
     - Parameter algorithm: The cryptographic algorithm to use.
     - Returns: The hash digest in `Data` format. This can then be converted to a base64 or hex
                string using the `base64String` or `hexString` extension methods.
     */
    func hash(algorithm: CryptoAlgorithm) -> Data {
        return withUnsafeBytes { dataBytes in
            algorithm.hash(dataBytes.baseAddress, dataLength: self.count)
        }
    }
}
