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

/**
 Common Communication Identifier protocol for all Azure Communication Services.
 All Communication Identifiers conform to this protocol.
 */
@objc public protocol CommunicationIdentifier: NSObjectProtocol {}
/**
 Communication identifier for Communication Services Users
 */
@objcMembers public class CommunicationUserIdentifier: NSObject, CommunicationIdentifier {
    public let identifier: String
    /**
     Creates a CommunicationUserIdentifier object
     - Parameter identifier: identifier representing the object identity
     */
    @objc(initWithIdentifier:)
    public init(_ identifier: String) {
        self.identifier = identifier
    }
}

/**
 Catch-all for all other Communication identifiers for Communication Services
 */
@objcMembers public class UnknownIdentifier: NSObject, CommunicationIdentifier {
    public let identifier: String
    /**
     Creates a UnknownIdentifier object
     - Parameter identifier: identifier representing the object identity
     */
    @objc(initWithIdentifier:)
    public init(_ identifier: String) {
        self.identifier = identifier
    }
}

/**
 Communication identifier for Communication Services representing a Phone Number
 */
@objcMembers public class PhoneNumberIdentifier: NSObject, CommunicationIdentifier {
    public let phoneNumber: String
    public let rawId: String?

    /**
     Creates a PhoneNumberIdentifier object
     - Parameter phoneNumber: phone number to create the object, different from identifier
     - Parameter rawId: The optional raw id of the phone number.
     */
    public init(phoneNumber: String, rawId: String? = nil) {
        self.phoneNumber = phoneNumber
        self.rawId = rawId
    }

    public static func == (lhs: PhoneNumberIdentifier, rhs: PhoneNumberIdentifier) -> Bool {
        if lhs.phoneNumber != rhs.phoneNumber {
            return false
        }

        return lhs.rawId == nil
            || rhs.rawId == nil
            || lhs.rawId == rhs.rawId
    }
}

/**
 Communication identifier for Microsoft Teams Users
 */
@objcMembers public class MicrosoftTeamsUserIdentifier: NSObject, CommunicationIdentifier {
    public let userId: String
    public let isAnonymous: Bool
    public let rawId: String?
    public let cloudEnviroment: CommunicationCloudEnvironment

    /**
     Creates a MicrosoftTeamsUserIdentifier object
     - Parameter userId: Id of the Microsoft Teams user. If the user isn't anonymous,
                            the id is the AAD object id of the user.
     - Parameter isAnonymous: Set this to true if the user is anonymous:
                                for example when joining a meeting with a share link.
     - Parameter rawId: The optional raw id of the Microsoft Teams User identifier.
     - Parameter cloudEnvironment: The cloud that the Microsoft Team user belongs to.
                                    A null value translates to the Public cloud.
     */
    public init(
        userId: String,
        isAnonymous: Bool = false,
        rawId: String? = nil,
        cloudEnvironment: CommunicationCloudEnvironment = .Public
    ) {
        self.rawId = rawId
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.cloudEnviroment = cloudEnvironment
    }

    public init(userId: String, isAnonymous: Bool) {
        self.cloudEnviroment = .Public
        self.rawId = nil
        self.userId = userId
        self.isAnonymous = isAnonymous
    }

    public static func == (lhs: MicrosoftTeamsUserIdentifier, rhs: MicrosoftTeamsUserIdentifier) -> Bool {
        if lhs.userId != rhs.userId ||
            lhs.isAnonymous != rhs.isAnonymous {
            return false
        }

        if lhs.cloudEnviroment != rhs.cloudEnviroment {
            return false
        }

        return lhs.rawId == nil
            || rhs.rawId == nil
            || lhs.rawId == rhs.rawId
    }
}
