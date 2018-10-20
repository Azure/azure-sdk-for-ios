//
//  TokenProvider.swift
//  AzurePush
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#if os(iOS)

import Foundation
import AzureCore

internal class TokenProvider {
    private static let defaultTokenTimeToLive: TimeInterval = 1200

    // MARK: -

    private struct Token {
        let value: String
        let obtainedAt: Date
        let timeToLive: TimeInterval

        var isExpired: Bool { return obtainedAt.addingTimeInterval(timeToLive) > Date() }
    }

    // MARK: -

    private let connectionParams: ConnectionParams

    // MARK: -

    private var cache: [URL: Token] = [:]

    // MARK: -

    internal init(connectionParams params: ConnectionParams) {
        self.connectionParams = params
    }

    internal func getToken(for url: URL) -> String? {
        if let token = cache[url], !token.isExpired {
            return token.value
        }

        let expiresOn = Int(Date().addingTimeInterval(TokenProvider.defaultTokenTimeToLive).timeIntervalSince1970 * 60)
        let audienceUri = url.absoluteString.replacingOccurrences(of: "https", with: "http").addingPercentEncodingWithAzureAllowedCharacters()?.lowercased()
        let signature = audienceUri.flatMap { CryptoProvider.hmacSHA256("\($0)\n\(expiresOn)", withUTF8Key: connectionParams.sharedAccessKey)?.addingPercentEncodingWithAzureAllowedCharacters() }

        if let audienceUri = audienceUri, let signature = signature {
            let token = "SharedAccessSignature sr=\(audienceUri)&sig=\(signature)&se=\(expiresOn)&skn=\(connectionParams.sharedAccessKeyName)"
            cache[url] = Token(value: token, obtainedAt: Date(), timeToLive: TokenProvider.defaultTokenTimeToLive)
            return token
        }

        return nil
    }
}

// MARK: -

extension String {
    fileprivate func addingPercentEncodingWithAzureAllowedCharacters() -> String? {
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: ".-")
        return self.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }

    fileprivate var base64Encoded: String? {
        return data(using: .utf8)?.base64EncodedString()
    }
}

extension CryptoProvider {
    fileprivate static func hmacSHA256(_ data: String, withUTF8Key key: String) -> String? {
        guard let base64Key = key.base64Encoded else { return nil }
        return CryptoProvider.hmacSHA256(data, withKey: base64Key)
    }
}

#endif
