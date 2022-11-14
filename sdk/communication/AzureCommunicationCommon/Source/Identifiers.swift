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
 The IdentifierKind for a given CommunicationIdentifier.
 */

@objcMembers public class IdentifierKind: NSObject {
    private var rawValue: String
    public static let communicationUser = IdentifierKind(rawValue: "communicationUser")
    public static let phoneNumber = IdentifierKind(rawValue: "phoneNumber")
    public static let microsoftTeamsUser = IdentifierKind(rawValue: "microsoftTeamsUser")
    public static let unknown = IdentifierKind(rawValue: "unknown")

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/**
 Common Communication Identifier protocol for all Azure Communication Services.
 All Communication Identifiers conform to this protocol.
 */
@objc public protocol CommunicationIdentifier: NSObjectProtocol {
    var rawId: String { get }
    var kind: IdentifierKind { get }
}

/**
 Creates a CommunicationIdentifierKind from a given rawId. When storing rawIds use this function to restore the identifier that was encoded in the rawId.
 - Parameter fromRawId: Id of the Microsoft Teams user. If the user isn't anonymous,The rawId to be translated to its identifier representation.
 */
public func createCommunicationIdentifier(fromRawId rawId: String) -> CommunicationIdentifier {
    let phoneNumberPrefix = "4:"
    let teamUserAnonymousPrefix = "8:teamsvisitor:"
    let teamUserPublicCloudPrefix = "8:orgid:"
    let teamUserDODCloudPrefix = "8:dod:"
    let teamUserGCCHCloudPrefix = "8:gcch:"
    let acsUser = "8:acs:"
    let spoolUser = "8:spool:"
    let dodAcsUser = "8:dod-acs:"
    let gcchAcsUser = "8:gcch-acs:"
    if rawId.hasPrefix(phoneNumberPrefix) {
        return PhoneNumberIdentifier(phoneNumber: String(rawId.dropFirst(phoneNumberPrefix.count)), rawId: rawId)
    }
    let segments = rawId.split(separator: ":")
    if segments.count < 3 {
        return UnknownIdentifier(rawId)
    }
    let scope = segments[0] + ":" + segments[1] + ":"
    let suffix = String(rawId.dropFirst(scope.count))
    switch scope {
    case teamUserAnonymousPrefix:
        return MicrosoftTeamsUserIdentifier(userId: suffix, isAnonymous: true)
    case teamUserPublicCloudPrefix:
        return MicrosoftTeamsUserIdentifier(
            userId: suffix,
            isAnonymous: false,
            rawId: rawId,
            cloudEnvironment: .Public
        )
    case teamUserDODCloudPrefix:
        return MicrosoftTeamsUserIdentifier(
            userId: suffix,
            isAnonymous: false,
            rawId: rawId,
            cloudEnvironment: .Dod
        )
    case teamUserGCCHCloudPrefix:
        return MicrosoftTeamsUserIdentifier(
            userId: suffix,
            isAnonymous: false,
            rawId: rawId,
            cloudEnvironment: .Gcch
        )
    case acsUser, spoolUser, dodAcsUser, gcchAcsUser:
        return CommunicationUserIdentifier(rawId)
    default:
        return UnknownIdentifier(rawId)
    }
}

/**
 Communication identifier for Communication Services Users
 */
@objcMembers public class CommunicationUserIdentifier: NSObject, CommunicationIdentifier {
    public var rawId: String { return identifier }
    public var kind: IdentifierKind { return .communicationUser }
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
    public var rawId: String { return identifier }
    public var kind: IdentifierKind { return .unknown }
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
    public private(set) var rawId: String
    public var kind: IdentifierKind { return .phoneNumber }

    /**
     Creates a PhoneNumberIdentifier object
     - Parameter phoneNumber: phone number to create the object, different from identifier
     - Parameter rawId: The optional raw id of the phone number.
     */
    public init(phoneNumber: String, rawId: String? = nil) {
        self.phoneNumber = phoneNumber
        if let rawId = rawId {
            self.rawId = rawId
        } else {
            self.rawId = "4:" + phoneNumber
        }
    }

    /**
     Returns a Boolean value indicating whether two values are equal.
        Note: In Objective-C favor isEqual() method
     - Parameter lhs PhoneNumberIdentifier to compare.
     - Parameter rhs  Another PhoneNumberIdentifier to compare.
     */
    // swiftlint:disable nsobject_prefer_isequal
    public static func == (lhs: PhoneNumberIdentifier, rhs: PhoneNumberIdentifier) -> Bool {
        return lhs.rawId == rhs.rawId
    }

    /**
     Returns a Boolean value that indicates whether the receiver is equal to another given object.
     This will automatically return false if object being compared to is not a PhoneNumberIdentifier.
     - Parameter object The object with which to compare the receiver.
     */
    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PhoneNumberIdentifier else {
            return false
        }

        return rawId == object.rawId
    }
}

/**
 Communication identifier for Microsoft Teams Users
 */
@objcMembers public class MicrosoftTeamsUserIdentifier: NSObject, CommunicationIdentifier {
    public let userId: String
    public let isAnonymous: Bool
    public private(set) var rawId: String
    public var kind: IdentifierKind { return .microsoftTeamsUser }
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
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.cloudEnviroment = cloudEnvironment

        if let rawId = rawId {
            self.rawId = rawId
        } else {
            if isAnonymous {
                self.rawId = "8:teamsvisitor:" + userId
            } else {
                switch cloudEnvironment {
                case .Dod:
                    self.rawId = "8:dod:" + userId
                case .Gcch:
                    self.rawId = "8:gcch:" + userId
                case .Public:
                    self.rawId = "8:orgid:" + userId
                default:
                    self.rawId = "8:orgid:" + userId
                }
            }
        }
    }

    /**
     Creates a MicrosoftTeamsUserIdentifier object. cloudEnvironment is defaulted to Public cloud.
     - Parameter userId: Id of the Microsoft Teams user. If the user isn't anonymous,
                            the id is the AAD object id of the user.
     - Parameter isAnonymous: Set this to true if the user is anonymous:
                                for example when joining a meeting with a share link.
     */
    convenience init(userId: String, isAnonymous: Bool) {
        self.init(userId: userId, isAnonymous: isAnonymous, rawId: nil, cloudEnvironment: .Public)
    }

    /**
     Returns a Boolean value indicating whether two values are equal.
        Note: In Objective-C favor isEqual() method
     - Parameter lhs MicrosoftTeamsUserIdentifier to compare.
     - Parameter rhs  Another MicrosoftTeamsUserIdentifier to compare.
     */
    // swiftlint:disable nsobject_prefer_isequal
    public static func == (lhs: MicrosoftTeamsUserIdentifier, rhs: MicrosoftTeamsUserIdentifier) -> Bool {
        return lhs.rawId == rhs.rawId
    }

    /**
     Returns a Boolean value that indicates whether the receiver is equal to another given object.
     This will automatically return false if object being compared to is not a MicrosoftTeamsUserIdentifier.
     - Parameter object The object with which to compare the receiver.
     */
    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? MicrosoftTeamsUserIdentifier else {
            return false
        }

        return rawId == object.rawId
    }
}
