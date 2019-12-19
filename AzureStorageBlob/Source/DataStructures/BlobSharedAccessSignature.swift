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
import Foundation

internal enum SASConstant: String {
    case signedSignature = "sig"
    case signedPermission = "sp"
    case signedStart = "st"
    case signedExpiry = "se"
    case signedResource = "sr"
    case signedIdentifier = "si"
    case signedIP = "sip"
    case signedProtocol = "spr"
    case signedVersion = "sv"
    case signedCacheControl = "rscc"
    case signedContentDisposition = "rscd"
    case signedContentEncoding = "rsce"
    case signedContentLanguage = "rscl"
    case signedContentType = "rsct"
    case startPK = "spk"
    case startRK = "srk"
    case endPK = "epk"
    case endRK = "erk"
    case signedResourceTypes = "srt"
    case signedServices = "ss"
    case signedOID = "skoid"
    case signedTID = "sktid"
    case signedKeyStart = "skt"
    case signedKeyExpiry = "ske"
    case signedKeyService = "sks"
    case signedKeyVersion = "skv"
    case signedTimestamp = "snapshot"
}

extension Dictionary where Key == SASConstant, Value == String {
    internal func convertToQueryItems() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        for (key, value) in self {
            queryItems.append(
                URLQueryItem(name: key.rawValue,
                             value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            )
        }
        return queryItems
    }

    mutating internal func addQuery(key: SASConstant, value: String?) {
        guard let val = value else { return }
        self[key] = val
    }
}

/// Class used to create Shared Access Signatures (SAS) for Blobs
public class BlobSharedAccessSignature {

    internal let account: String

    internal let accountKey: String?

    internal let userDelegationKey: UserDelegationKey?

    internal let options: BlobSasOptions

    internal var queryDict: [SASConstant: String]

    // MARK: Initializers

    /**
     - Parameter account: The storage account name used to generate the shared access signatures.
     - Parameter accountKey: The storage account key used to generate the shared access signatures.
     - Parameter options: A `BlobSasOptions` object used to control the shared access signature generation.
     - Returns: A `BlobSharedAccessSignature` object.
     */
    public init(account: String, accountKey: String, options: BlobSasOptions? = nil) {
        self.account = account
        self.accountKey = accountKey
        self.userDelegationKey = nil
        self.options = options ?? BlobSasOptions()
        self.queryDict = [SASConstant: String]()
    }

    /**
     - Parameter account: The storage account name used to generate the shared access signatures.
     - Parameter userDelegationKey: Instead of an account key, the user could pass in a user delegation key.
        A user delegation key can be obtained from the service by authenticating with an AAD identity.
     - Parameter options: A `BlobSasOptions` object used to control the shared access signature generation.
     - Returns: A `BlobSharedAccessSignature` object.
     */
    public init(account: String, userDelegationKey: UserDelegationKey, options: BlobSasOptions? = nil) {
        self.account = account
        self.accountKey = nil
        self.userDelegationKey = userDelegationKey
        self.options = options ?? BlobSasOptions()
        self.queryDict = [SASConstant: String]()
    }

    // MARK: Public Methods

    /**
     Generates a shared access signature for the blob or one of its snapshots.
     Use the returned signature with the `sasToken` parameter of any `StorageBlobClient`.
     - Parameter blob: The name of the blob.
     - Parameter container: The name of the container.
     - Returns: The SAS token for the specified blob, which can be used with the `sasToken` parameter
     of any `StorageBlobClient`.
     */
    public func token(forBlob blob: String, inContainer container: String) throws -> String {
        let signedResource = options.snapshot == nil ? "b" : "bs"
        queryDict.addQuery(key: SASConstant.signedStart, value: options.start)
        queryDict.addQuery(key: SASConstant.signedExpiry, value: options.expiry)
        queryDict.addQuery(key: SASConstant.signedPermission, value: options.permission)
        queryDict.addQuery(key: SASConstant.signedIP, value: options.ip)
        queryDict.addQuery(key: SASConstant.signedProtocol, value: options.protocol)
        // TODO: This comes from the client.
        // queryDict.addQuery(key: SASConstant.signedVersion.rawValue, value: self.options.apiVersion)
        queryDict.addQuery(key: SASConstant.signedIdentifier, value: options.policyId)
        queryDict.addQuery(key: SASConstant.signedResource, value: signedResource)
        queryDict.addQuery(key: SASConstant.signedTimestamp, value: options.snapshot)
        queryDict.addQuery(key: SASConstant.signedCacheControl, value: options.cacheControl)
        queryDict.addQuery(key: SASConstant.signedContentDisposition, value: options.contentDisposition)
        queryDict.addQuery(key: SASConstant.signedContentEncoding, value: options.contentEncoding)
        queryDict.addQuery(key: SASConstant.signedContentLanguage, value: options.contentLanguage)
        queryDict.addQuery(key: SASConstant.signedContentType, value: options.contentType)

        try signResource(atPath: "\(container)/\(blob)")

        // A conscious decision was made to exclude the timestamp in the generated token
        // to avoid having two snapshot IDs in the query parameters when the user appends the snapshot timestamp
        _ = queryDict.removeValue(forKey: SASConstant.signedTimestamp)
        let queryItems = queryDict.convertToQueryItems()
        var strings = [String]()
        for item in queryItems where item.value != nil {
            strings.append("\(item.name)=\(item.value!)")
        }
        return "&" + strings.joined(separator: ";")
    }

    // MARK: Private Methods

    private func valueToSign(forKey key: SASConstant) -> String {
        return (queryDict[key] ?? "") + "\n"
    }

    private func sign(string stringToSign: String, withAccountKey key: String, isBase64: Bool = true) throws -> String {
        let error = AzureError.general("Unable to sign string with key.")
        var keyData: Data?
        if isBase64 {
            keyData = Data(base64Encoded: key)
        } else {
            keyData = key.data(using: .utf8)
        }
        guard let signingKey = keyData else { throw error }
        guard let signedHmacSha256 = try? stringToSign.hmac(algorithm: .sha256, key: signingKey) else { throw error }
        return signedHmacSha256.base64String
    }

    private func sign(string: String, withUserDelegationKey: UserDelegationKey,
                      isBase64: Bool = true) throws -> String {
        return ""
    }

    private func signResource(atPath path: String) throws {

        let modPath = path.hasPrefix("/") ? path : "/\(path)"
        let canonicalizedResource = "/blob/\(account)\(modPath)\n"

        // Form the string to sign from sharedAccessPolicy and canonicalized
        // resource. The order of values is important.
        var stringToSign = (
            valueToSign(forKey: .signedPermission) +
            valueToSign(forKey: .signedStart) +
            valueToSign(forKey: .signedExpiry) +
            canonicalizedResource
        )
        if let key = userDelegationKey {
            queryDict.addQuery(key: .signedOID, value: key.signedOID)
            queryDict.addQuery(key: .signedKeyStart, value: key.signedStart)
            queryDict.addQuery(key: .signedKeyExpiry, value: key.signedExpiry)
            queryDict.addQuery(key: .signedKeyService, value: key.signedService)
            queryDict.addQuery(key: .signedKeyVersion, value: key.signedVersion)
            stringToSign += (
                valueToSign(forKey: .signedOID) +
                valueToSign(forKey: .signedTID) +
                valueToSign(forKey: .signedKeyStart) +
                valueToSign(forKey: .signedKeyExpiry) +
                valueToSign(forKey: .signedKeyService) +
                valueToSign(forKey: .signedKeyVersion)
            )
        } else {
            stringToSign += valueToSign(forKey: .signedIdentifier)
        }

        stringToSign += (
            valueToSign(forKey: .signedIP) +
            valueToSign(forKey: .signedProtocol) +
            valueToSign(forKey: .signedVersion) +
            valueToSign(forKey: .signedResource) +
            valueToSign(forKey: .signedTimestamp) +
            valueToSign(forKey: .signedCacheControl) +
            valueToSign(forKey: .signedContentDisposition) +
            valueToSign(forKey: .signedContentEncoding) +
            valueToSign(forKey: .signedContentLanguage) +
            valueToSign(forKey: .signedContentType)
        )

        // remove the trailing newline
        if stringToSign.hasSuffix("\n") {
            stringToSign = String(stringToSign.dropLast("\n".count))
        }
        var signature = ""
        if let key = userDelegationKey {
            signature = try sign(string: stringToSign, withUserDelegationKey: key)
        } else if let key = accountKey {
            signature = try sign(string: stringToSign, withAccountKey: key)
        }
        queryDict.addQuery(key: .signedSignature, value: signature)
    }
}
