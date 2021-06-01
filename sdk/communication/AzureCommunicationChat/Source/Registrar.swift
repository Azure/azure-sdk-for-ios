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

import Foundation
import AzureCommunicationCommon

/// Client description for set registration requests.
internal struct RegistrationClientDescription {
    /// The AppId.
    internal let appId: String
    /// IETF Language tags.
    internal let language: [String]
    /// Client platform.
    internal let platform: String
    /// Platform ID.
    internal let platformUiVersion: String
    /// Template key.
    internal let templateKey: String
    /// Template version.
    internal let templateVersion: String

    internal init(
        appId: String,
        language: [String],
        platform: String,
        platformUiVersion: String,
        templateKey: String,
        templateVersion: String
    ) {
        self.appId = appId
        self.language = language
        self.platform = platform
        self.platformUiVersion = platformUiVersion
        self.templateKey = templateKey
        self.templateVersion = templateVersion
    }
}

internal struct RegistrationTransports {
    /// TTL in seconds. Maximum value is 15552000.
    internal let ttl: Int
    /// Registration path.
    internal let path: String
    /// Optional context.
    internal let context: String?
    /// Creation time as RFC 1123 formatted date.
    internal let creationTime: String?
    /// Snooze time in seconds. Maximum value is 15552000.
    internal let snoozeSeconds: Int?

    internal init(
        ttl: Int,
        path: String,
        context: String? = nil,
        creationTime: String? = nil,
        snoozeSeconds: Int? = nil
    ) {
        self.ttl = ttl
        self.path = path
        self.context = context
        self.creationTime = creationTime
        self.snoozeSeconds = snoozeSeconds
    }
}


internal class Registrar {
    // MARK: Properties

    /// Registrar API endpoint.
    private let endpoint: String
    /// CommunicationTokenCredential for authorizing requests.
    private let credential: CommunicationTokenCredential
    /// Unique identifier for the registration.
    private let registrationId: String

    // MARK: Initializers

    internal init(
        endpoint: String,
        credential: CommunicationTokenCredential,
        registrationId: String
    ) {
        self.endpoint = endpoint
        self.credential = credential
        self.registrationId = registrationId
    }

    // MARK: Internal Methods

    internal func setRegistration(
        deviceToken: String,
        clientDescription: RegistrationClientDescription,
        transports: RegistrationTransports
    ) {
        // Given params
        // Send POST request with skypetoken header
        // Return Result
        
        // What should ttl be?
    }
    
    internal func deleteRegistration(
    ) {
        // Given params
        // Send DELETE request with skypetoken header
        // Return Result
    }
}
