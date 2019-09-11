//
//  CryptoUtils.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/9/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import CommonCrypto
import Foundation

extension Array where Element == UInt8 {
    public var sha256: [UInt8] {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = self.withUnsafeBytes {
            CC_SHA256($0.baseAddress, UInt32(self.count), &digest)
        }
        return digest
    }
    
    public var base64String: String {
        let data = Data(bytes: self, count: self.count)
        return data.base64EncodedString()
    }
    
    public var hexString: String {
        return self.compactMap({ String(format: "%02x", $0) }).joined().uppercased()
    }
}

//    kCCHmacAlgSHA1,
//    kCCHmacAlgMD5,
//    kCCHmacAlgSHA256,
//    kCCHmacAlgSHA384,
//    kCCHmacAlgSHA512,
//    kCCHmacAlgSHA224
public enum HmacAlgorithm {
    case sha1, md5, sha256, sha384, sha512, sha224
    public var algorithm: CCHmacAlgorithm {
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

extension String {
    public func hmac(algorithm: HmacAlgorithm, key: Data) -> [UInt8] {
        var digest = [UInt8](repeating: 0, count: algorithm.digestLength)
        key.withUnsafeBytes { keyBytes in
            CCHmac(algorithm.algorithm, keyBytes, key.count, String(self.utf8), self.count, &digest)
        }
        return digest
    }
    
    public var base64String: String {
        let data = Data(bytes: self, count: self.count)
        return data.base64EncodedString()
    }
    
    public var decodeHex: Data? {
        var data = Data(capacity: self.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        guard data.count > 0 else { return nil }
        return data
    }
    
    public var decodeBase64: Data? {
        return Data(base64Encoded: self)
    }
}
