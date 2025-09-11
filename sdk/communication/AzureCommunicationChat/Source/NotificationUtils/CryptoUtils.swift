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
import AzureCore
#if canImport(CommonCrypto)
import CommonCrypto
#endif
#if canImport(CryptoKit)
import CryptoKit
#endif
import Foundation

class CryptoUtils {
    static let ciperModeSize: Int = 1
    static let initializationVectorSize: Int = 16
    static let hmacSize: Int = 32

    static func extractInitializationVector(result: [UInt8]) -> [UInt8] {
        return copyOfRange(
            originalArr: result,
            startIdx: ciperModeSize,
            endIdx: ciperModeSize + initializationVectorSize
        )
    }

    static func extractCipherText(result: [UInt8]) -> [UInt8] {
        return copyOfRange(
            originalArr: result,
            startIdx: ciperModeSize + initializationVectorSize,
            endIdx: ciperModeSize + initializationVectorSize +
                (result.count - hmacSize - ciperModeSize - initializationVectorSize)
        )
    }

    static func extractHmac(result: [UInt8]) -> [UInt8] {
        let testArr1 = copyOfRange(originalArr: result, startIdx: result.count - hmacSize, endIdx: result.count)
        print("Print hmac:", String(decoding: testArr1, as: UTF8.self))
        return testArr1
    }

    static func extractCipherModeIVCipherText(result: [UInt8]) -> [UInt8] {
        let testArr = copyOfRange(originalArr: result, startIdx: 0, endIdx: result.count - hmacSize)
        print("Print cipherModeIVText:", String(decoding: testArr, as: UTF8.self))
        return testArr
    }
}

func copyOfRange(originalArr: [UInt8], startIdx: Int, endIdx: Int) -> [UInt8] {
    var arrCopy = [UInt8](repeating: 0, count: endIdx - startIdx)
    for idx in startIdx ..< endIdx {
        arrCopy[idx - startIdx] = originalArr[idx]
    }
    return arrCopy
}

// Verify HMAC SHA256 signature using CryptoKit Framework
func verifyEncryptedPayload(cipherModeIVCipherText: [UInt8], authKey: String, actualHmac: [UInt8]) throws -> Bool {
    // 1.Calculate SHA256 key
    guard let data = Data(base64Encoded: authKey) else {
        throw AzureError
            .client(
                "Failed to initialize a data object with the given authKey. Please ensure the authKey is a Base64 encoded string."
            )
    }
    let digest = SHA256.hash(data: data)
    let key = SymmetricKey(data: digest.data)

    // 2.Computed HMAC signature
    let signature = HMAC<SHA256>.authenticationCode(for: Data(cipherModeIVCipherText), using: key)
    let calculatedHMACHex = Data(signature).map { String(format: "%02hhx", $0) }.joined()
    print("calculatedMac:\(calculatedHMACHex)")

    // 3.Included HMAC signature
    let actualHMACHex = Data(actualHmac).map { String(format: "%02hhx", $0) }.joined()
    print("actualHmac:\(actualHMACHex)")

    return actualHMACHex == calculatedHMACHex
}

extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }
}

// Decrypt the notification payload using CommonCrypto Framework
func decryptPushNotificationPayload(cipherText: [UInt8], iv: [UInt8], cryptoKey: String) throws -> String {
    guard let decodedData = Data(base64Encoded: cryptoKey) else {
        throw AzureError
            .client(
                "Failed to initialize a data object with the given cryptoKey. Please ensure the cryptoKey is a Base64 encoded string."
            )
    }

    let keyBytes = Array(decodedData)

    let cryptLength = size_t(cipherText.count + kCCBlockSizeAES128)
    var cryptData = [UInt8](repeating: 0, count: cryptLength)

    let keyLength = size_t(kCCKeySizeAES256)
    let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES)
    let options: CCOptions = UInt32(kCCOptionPKCS7Padding)

    var numBytesEncrypted: size_t = 0

    let cryptStatus = CCCrypt(
        CCOperation(kCCDecrypt),
        algoritm,
        options,
        keyBytes,
        keyLength,
        iv,
        cipherText,
        cipherText.count,
        &cryptData,
        cryptLength,
        &numBytesEncrypted
    )
    if UInt32(cryptStatus) == UInt32(kCCSuccess) {
        cryptData.removeSubrange(numBytesEncrypted ..< cryptData.count)
    } else {
        throw AzureError.client("Error in decrypting Notification Payload: \(cryptStatus)")
    }

    return String(decoding: cryptData, as: UTF8.self)
}

internal func generateEncryptionKey() -> String {
    return SymmetricKey(size: .init(bitCount: 512)).serialize()
}

// Use the SymmetricKey class in CryptoKit framework to create encryption keys
extension SymmetricKey {
    /// Serializes a `SymmetricKey` to a Base64-encoded `String`.
    func serialize() -> String {
        return withUnsafeBytes { body in
            Data(body).base64EncodedString()
        }
    }
}

func splitEncryptionKey(encryptionKey: String) throws -> [String] {
    guard var data = Data(base64Encoded: encryptionKey, options: .ignoreUnknownCharacters) else {
        throw AzureError
            .client("Failed to convert base64Encoded string into Data format.")
    }
    var aesArr: [UInt8] = .init(repeating: 0, count: 32)
    var authArr: [UInt8] = .init(repeating: 0, count: 32)

    for idx in 0 ..< 64 {
        if idx < 32 {
            aesArr[idx] = data.remove(at: 0)
        } else {
            authArr[idx - 32] = data.remove(at: 0)
        }
    }

    let aesKey = Data(aesArr).base64EncodedString()
    let authKey = Data(authArr).base64EncodedString()

    return [aesKey, authKey]
}
