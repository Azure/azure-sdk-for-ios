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
#if canImport(os)
import os.log
#endif

/**
 The IdentifierKind for a given CommunicationIdentifier.
 */
@objcMembers public class IdentifierKind: NSObject {
    private var rawValue: String
    public static let communicationUser = IdentifierKind(rawValue: "communicationUser")
    public static let phoneNumber = IdentifierKind(rawValue: "phoneNumber")
    public static let microsoftTeamsUser = IdentifierKind(rawValue: "microsoftTeamsUser")
    public static let microsoftTeamsApp = IdentifierKind(rawValue: "microsoftTeamsApp")
    public static let teamsExtensionUser = IdentifierKind(rawValue: "teamsExtensionUser")
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

internal enum Prefix {
    public static let PhoneNumber = "4:"
    public static let TeamsAppPublicCloud = "28:orgid:"
    public static let TeamsAppDodCloud = "28:dod:"
    public static let TeamsAppGcchCloud = "28:gcch:"
    public static let TeamsUserAnonymous = "8:teamsvisitor:"
    public static let TeamsUserPublicCloud = "8:orgid:"
    public static let TeamsUserDodCloud = "8:dod:"
    public static let TeamsUserGcchCloud = "8:gcch:"
    public static let AcsUser = "8:acs:"
    public static let AcsUserDodCloud = "8:dod-acs:"
    public static let AcsUserGcchCloud = "8:gcch-acs:"
    public static let SpoolUser = "8:spool:"
}

/**
 Creates a CommunicationIdentifierKind from a given rawId. When storing rawIds use this function to restore the identifier that was encoded in the rawId.
 - Parameter fromRawId: Id of the Microsoft Teams user. If the user isn't anonymous,The rawId to be translated to its identifier representation.
 */
public func createCommunicationIdentifier(fromRawId rawId: String) -> CommunicationIdentifier {
    if rawId.hasPrefix(Prefix.PhoneNumber) {
        return PhoneNumberIdentifier(phoneNumber: String(rawId.dropFirst(Prefix.PhoneNumber.count)), rawId: rawId)
    }
    let segments = rawId.split(separator: ":")
    let segmentCounts = segments.count
    if segmentCounts != 3 {
        return UnknownIdentifier(rawId)
    }
    let scope = segments[0] + ":" + segments[1] + ":"
    let suffix = String(segments[2])
    switch scope {
    case Prefix.TeamsUserAnonymous:
        return MicrosoftTeamsUserIdentifier(userId: suffix, isAnonymous: true)
    case Prefix.TeamsUserPublicCloud:
        return MicrosoftTeamsUserIdentifier(userId: suffix, isAnonymous: false, rawId: rawId, cloudEnvironment: .Public)
    case Prefix.TeamsUserDodCloud:
        return MicrosoftTeamsUserIdentifier(userId: suffix, isAnonymous: false, rawId: rawId, cloudEnvironment: .Dod)
    case Prefix.TeamsUserGcchCloud:
        return MicrosoftTeamsUserIdentifier(userId: suffix, isAnonymous: false, rawId: rawId, cloudEnvironment: .Gcch)
    case Prefix.TeamsAppPublicCloud:
        return MicrosoftTeamsAppIdentifier(appId: suffix, cloudEnvironment: .Public)
    case Prefix.TeamsAppDodCloud:
        return MicrosoftTeamsAppIdentifier(appId: suffix, cloudEnvironment: .Dod)
    case Prefix.TeamsAppGcchCloud:
        return MicrosoftTeamsAppIdentifier(appId: suffix, cloudEnvironment: .Gcch)
    case Prefix.SpoolUser:
        return CommunicationUserIdentifier(rawId)
    case Prefix.AcsUser,
         Prefix.AcsUserDodCloud,
         Prefix.AcsUserGcchCloud:
        return buildCorrectCommunicationIdentifier(prefix: scope, suffix: suffix)
    default:
        return UnknownIdentifier(rawId)
    }
}

private func buildCorrectCommunicationIdentifier(prefix: String, suffix: String) -> CommunicationIdentifier {
    let segments = suffix.split(separator: "_")
    guard segments.count == 3 else {
        return CommunicationUserIdentifier(prefix + suffix)
    }
    let resourceId = String(segments[0])
    let tenantId = String(segments[1])
    let userId = String(segments[2])

    let cloud: CommunicationCloudEnvironment = {
        switch prefix {
        case Prefix.AcsUserDodCloud: return .Dod
        case Prefix.AcsUserGcchCloud: return .Gcch
        default: return .Public
        }
    }()

    return TeamsExtensionUserIdentifier(
        userId: userId,
        tenantId: tenantId,
        resourceId: resourceId,
        cloudEnvironment: cloud
    )
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
 It is not advisable to rely on this type of identifier, as UnknownIdentifier could become a new or existing distinct type in the future.
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
        super.init()
        logUsageWarning()
    }

    private func logUsageWarning() {
        let subsystem = "com.azure"
        let category = "AzureCommunicationCommon"
        let message = "It is not advisable to rely on this type of identifier"
            + "as UnknownIdentifier could become a new or existing distinct type in the future."
        let osLog = OSLog(subsystem: subsystem, category: category)
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            let logger = Logger(osLog)
            logger.info("\(message)")
        } else {
            os_log("%@", log: osLog, type: .info, message)
        }
    }
}

/**
 Communication identifier for Communication Services representing a Phone Number
 */
@objcMembers public class PhoneNumberIdentifier: NSObject, CommunicationIdentifier {
    public let phoneNumber: String
    /// The asserted Id is set on a phone number that is already in the same call to distinguish from other connections
    /// made through the same number.
    public let assertedId: String?
    /// True if the phone number is anonymous, e.g. when used to represent a hidden caller Id.
    public let isAnonymous: Bool
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
        let phoneNumberFromRawId = String(self.rawId.dropFirst(Prefix.PhoneNumber.count))
        self.isAnonymous = phoneNumber == "anonymous"
        self.assertedId = PhoneNumberIdentifier.extractAssertedId(from: phoneNumberFromRawId, isAnonymous: isAnonymous)
    }

    private static func extractAssertedId(from phoneNumber: String, isAnonymous: Bool) -> String? {
        guard !isAnonymous,
              let lastUnderscoreIndex = phoneNumber.lastIndex(of: "_"),
              lastUnderscoreIndex != phoneNumber.startIndex,
              lastUnderscoreIndex != phoneNumber.index(before: phoneNumber.endIndex)
        else {
            return nil
        }
        let assertedIdStart = phoneNumber.index(after: lastUnderscoreIndex)
        return String(phoneNumber[assertedIdStart...])
    }

    // swiftlint:disable:next nsobject_prefer_isequal
    /**
     Returns a Boolean value indicating whether two values are equal.
        Note: In Objective-C favor isEqual() method
     - Parameter lhs PhoneNumberIdentifier to compare.
     - Parameter rhs  Another PhoneNumberIdentifier to compare.
     */
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
    @available(*, deprecated, renamed: "cloudEnvironment")
    public let cloudEnviroment: CommunicationCloudEnvironment
    public let cloudEnvironment: CommunicationCloudEnvironment

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
        self.cloudEnvironment = cloudEnvironment
        self.cloudEnviroment = cloudEnvironment
        if let rawId = rawId {
            self.rawId = rawId
        } else {
            if isAnonymous {
                self.rawId = Prefix.TeamsUserAnonymous + userId
            } else {
                switch cloudEnvironment {
                case .Dod:
                    self.rawId = Prefix.TeamsUserDodCloud + userId
                case .Gcch:
                    self.rawId = Prefix.TeamsUserGcchCloud + userId
                default:
                    self.rawId = Prefix.TeamsUserPublicCloud + userId
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

    // swiftlint:disable:next nsobject_prefer_isequal
    /**
     Returns a Boolean value indicating whether two values are equal.
        Note: In Objective-C favor isEqual() method
     - Parameter lhs MicrosoftTeamsUserIdentifier to compare.
     - Parameter rhs  Another MicrosoftTeamsUserIdentifier to compare.
     */
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

/**
 Communication identifier for Microsoft Teams applications.
 */
@objcMembers public class MicrosoftTeamsAppIdentifier: NSObject, CommunicationIdentifier {
    public let appId: String
    public let cloudEnvironment: CommunicationCloudEnvironment
    public var rawId: String
    public var kind: IdentifierKind { return .microsoftTeamsApp }

    /**
     Creates a MicrosoftTeamsAppIdentifier object
     - Parameter appId: The id of the Microsoft Teams application.
     - Parameter cloudEnvironment: The cloud that the Microsoft Teams application belongs to.
                                    A null value translates to the Public cloud.
     */
    public init(
        appId: String,
        cloudEnvironment: CommunicationCloudEnvironment = .Public
    ) {
        self.appId = appId
        self.cloudEnvironment = cloudEnvironment

        switch cloudEnvironment {
        case .Dod:
            self.rawId = Prefix.TeamsAppDodCloud + appId
        case .Gcch:
            self.rawId = Prefix.TeamsAppGcchCloud + appId
        default:
            self.rawId = Prefix.TeamsAppPublicCloud + appId
        }
    }

    // swiftlint:disable:next nsobject_prefer_isequal
    /**
     Returns a Boolean value indicating whether two values are equal.
        Note: In Objective-C favor isEqual() method
     - Parameter lhs MicrosoftTeamsAppIdentifier to compare.
     - Parameter rhs  Another MicrosoftTeamsAppIdentifier to compare.
     */
    public static func == (lhs: MicrosoftTeamsAppIdentifier, rhs: MicrosoftTeamsAppIdentifier) -> Bool {
        return lhs.rawId == rhs.rawId
    }

    /**
     Returns a Boolean value that indicates whether the receiver is equal to another given object.
     This will automatically return false if object being compared to is not a MicrosoftTeamsAppIdentifier.
     - Parameter object The object with which to compare the receiver.
     */
    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? MicrosoftTeamsAppIdentifier else {
            return false
        }

        return rawId == object.rawId
    }
}

/**
 Communication identifier for Microsoft Teams Phone user who is using a Communication Services resource to extend their Teams Phone set up.
 */
@objcMembers public class TeamsExtensionUserIdentifier: NSObject, CommunicationIdentifier {
    /// The Id of the Microsoft Teams Extension user, i.e. the Entra ID object Id of the user.
    public let userId: String
    /// The tenant Id of the Microsoft Teams Extension user.
    public let tenantId: String
    /// The Communication Services resource Id.
    public let resourceId: String
    public private(set) var rawId: String
    public var kind: IdentifierKind { return .teamsExtensionUser }
    /// The cloud that the identifier belongs to.
    public let cloudEnvironment: CommunicationCloudEnvironment

    /**
     Creates a TeamsExtensionUserIdentifier object
     - Parameter userId: The Id of the Microsoft Teams Extension user, i.e. the Entra ID object Id of the user.
     - Parameter tenantId: The tenant Id of the Microsoft Teams Extension user.
     - Parameter resourceId: The Communication Services resource Id
     - Parameter rawId: The optional raw id of the Microsoft Teams Phone user identifier.
     - Parameter cloudEnvironment: The cloud that the Microsoft Teams Phone user belongs to.
                                        A null value translates to the Public cloud.
     */
    public init(
        userId: String,
        tenantId: String,
        resourceId: String,
        rawId: String? = nil,
        cloudEnvironment: CommunicationCloudEnvironment = .Public
    ) {
        self.userId = userId
        self.tenantId = tenantId
        self.resourceId = resourceId
        self.cloudEnvironment = cloudEnvironment
        if let rawId = rawId {
            self.rawId = rawId
        } else {
            switch cloudEnvironment {
            case .Dod:
                self.rawId = "\(Prefix.AcsUserDodCloud)\(resourceId)_\(tenantId)_\(userId)"
            case .Gcch:
                self.rawId = "\(Prefix.AcsUserGcchCloud)\(resourceId)_\(tenantId)_\(userId)"
            default:
                self.rawId = "\(Prefix.AcsUser)\(resourceId)_\(tenantId)_\(userId)"
            }
        }
    }

    // swiftlint:disable:next nsobject_prefer_isequal
    /**
     Returns a Boolean value indicating whether two values are equal.
        Note: In Objective-C favor isEqual() method
     - Parameter lhs MicrosoftTeamsUserIdentifier to compare.
     - Parameter rhs  Another MicrosoftTeamsUserIdentifier to compare.
     */
    public static func == (lhs: TeamsExtensionUserIdentifier, rhs: TeamsExtensionUserIdentifier) -> Bool {
        return lhs.rawId == rhs.rawId
    }

    /**
     Returns a Boolean value that indicates whether the receiver is equal to another given object.
     This will automatically return false if object being compared to is not a TeamsExtensionUserIdentifier.
     - Parameter object The object with which to compare the receiver.
     */
    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TeamsExtensionUserIdentifier else {
            return false
        }

        return rawId == object.rawId
    }
}
