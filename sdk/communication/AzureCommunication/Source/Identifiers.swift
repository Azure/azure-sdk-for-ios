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
 Common Communication Identifier protocol for all Azure Communication Services. All Communication Identifiers conform to this protocol.
 */
@objc public protocol CommunicationIdentifier: NSObjectProtocol {  }
/**
 Communication identifier for Communication Services Users
 */
@objcMembers public class CommunicationUser: NSObject, CommunicationIdentifier {
    public let identifier: String
    /**
     Creates a CommunicationUser object
     - Parameter identifier: identifier representing the object identity
     */
    public init(identifier: String) {
        self.identifier = identifier
    }
}
/**
 Communication identifier for Communication Services Applications
 */
@objcMembers public class CallingApplication: NSObject, CommunicationIdentifier {
    public let identifier: String
    /**
     Creates a CallingApplication object
     - Parameter identifier: identifier representing the object identity
     */
    public init(identifier: String) {
        self.identifier = identifier
    }
}
/**
 Catch-all for all other Communication identifiers for Communication Services
 */
@objcMembers public class UnknownIdentifier: NSObject, CommunicationIdentifier {
    public let identifier: String
    /**
     Creates a CallingApplication object
     - Parameter identifier: identifier representing the object identity
     */
    public init(identifier: String) {
        self.identifier = identifier
    }
}
/**
 Communication identifier for Communication Services representing a Phone Number
 */
@objcMembers public class PhoneNumber: NSObject, CommunicationIdentifier {
    public let value: String
    /**
     Creates a Phone Number object
     - Parameter phoneNumber: phone number to create the object, different from identifier
     */
    public init(phoneNumber: String) {
        self.value = phoneNumber
    }
}
