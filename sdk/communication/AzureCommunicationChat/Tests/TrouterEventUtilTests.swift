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
import AzureCommunicationCommon
@testable import AzureCommunicationChat
import Trouter
import XCTest

class TrouterRequestMock: NSObject, TrouterRequest {
    let id: Int
    let method: String
    let path: String
    let headers: [AnyHashable: Any]
    let body: String

    init(
        id: Int,
        method: String,
        path: String,
        headers: [AnyHashable: Any],
        body: String
    ) {
        self.id = id
        self.method = method
        self.path = path
        self.headers = headers
        self.body = body
    }
}

class TrouterEventUtilTests: XCTestCase {

    func test_createChatMessageReceivedEvent_withSenderDisplayName() {
        do {
            let payload = """
                {
                    "_eventId": 200,
                    "senderId": "8:acs:senderId",
                    "recipientId": "acs:recipientId",
                    "transactionId": "transactionId",
                    "groupId": "thread123",
                    "messageId": "123",
                    "collapseId": "collapseId",
                    "messageType": "Text",
                    "messageBody": "Hello!",
                    "senderDisplayName": "SenderName",
                    "clientMessageId": "",
                    "originalArrivalTime": "2021-08-26T20:25:58.742Z",
                    "priority": "",
                    "version": "456"
                }
            """

            let trouterRequest = TrouterRequestMock(
                id: 1,
                method: "POST",
                path: "",
                headers: [
                    "ms-cv": "abcd"
                ],
                body: payload
            )

            let result = try TrouterEventUtil.create(chatEvent: .chatMessageReceived, from: trouterRequest)
            
            switch result {
            case let .chatMessageReceivedEvent(event):
                XCTAssertEqual(event.id, "123")
                XCTAssertEqual(event.createdOn, Iso8601Date(string: "2021-08-26T20:25:58.742Z"))
                XCTAssertEqual(event.message, "Hello!")
                XCTAssertEqual(event.senderDisplayName, "SenderName")
                XCTAssertEqual(event.threadId, "thread123")
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, "456")

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, "8:acs:recipientId")

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, "8:acs:senderId")
            default:
                XCTFail("Did not create ChatMessageReceivedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatMessageReceivedEvent: \(error)")
        }
    }

    func test_createChatMessageReceivedEvent_withoutSenderDisplayName() {
        do {
            let payload = """
                {
                    "_eventId": 200,
                    "senderId": "8:acs:senderId",
                    "recipientId": "acs:recipientId",
                    "transactionId": "transactionId",
                    "groupId": "thread123",
                    "messageId": "123",
                    "collapseId": "collapseId",
                    "messageType": "Text",
                    "messageBody": "Hello!",
                    "senderDisplayName": "",
                    "clientMessageId": "",
                    "originalArrivalTime": "2021-08-26T20:25:58.742Z",
                    "priority": "",
                    "version": "456"
                }
            """

            let trouterRequest = TrouterRequestMock(
                id: 1,
                method: "POST",
                path: "",
                headers: [
                    "ms-cv": "abcd"
                ],
                body: payload
            )

            let result = try TrouterEventUtil.create(chatEvent: .chatMessageReceived, from: trouterRequest)
            
            switch result {
            case let .chatMessageReceivedEvent(event):
                XCTAssertEqual(event.id, "123")
                XCTAssertEqual(event.createdOn, Iso8601Date(string: "2021-08-26T20:25:58.742Z"))
                XCTAssertEqual(event.message, "Hello!")
                XCTAssertEqual(event.senderDisplayName, "")
                XCTAssertEqual(event.threadId, "thread123")
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, "456")

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, "8:acs:recipientId")

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, "8:acs:senderId")
            default:
                XCTFail("Did not create ChatMessageReceivedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatMessageReceivedEvent: \(error)")
        }
    }

    func test_createChatMessageEdited_withSenderDisplayName() {
        do {
            let payload = """
                {
                    "_eventId": 247,
                    "senderId": "8:acs:senderId",
                    "recipientId": "acs:recipientId",
                    "transactionId": "transactionId",
                    "groupId": "thread123",
                    "messageId": "123",
                    "collapseId": "collapseId",
                    "messageType": "Text",
                    "messageBody": "Hello!",
                    "senderDisplayName": "SenderName",
                    "clientMessageId": "",
                    "originalArrivalTime": "2021-08-26T20:30:09.593Z",
                    "priority": "",
                    "version": "456",
                    "edittime": "2021-08-26T20:33:17.651Z",
                    "composetime": "2021-08-26T20:30:09.593Z"
                }
            """

            let trouterRequest = TrouterRequestMock(
                id: 1,
                method: "POST",
                path: "",
                headers: [
                    "ms-cv": "abcd"
                ],
                body: payload
            )

            let result = try TrouterEventUtil.create(chatEvent: .chatMessageEdited, from: trouterRequest)
            
            switch result {
            case let .chatMessageEdited(event):
                XCTAssertEqual(event.id, "123")
                XCTAssertEqual(event.createdOn, Iso8601Date(string: "2021-08-26T20:30:09.593Z"))
                XCTAssertEqual(event.message, "Hello!")
                XCTAssertEqual(event.senderDisplayName, "SenderName")
                XCTAssertEqual(event.threadId, "thread123")
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, "456")
                XCTAssertEqual(event.editedOn, Iso8601Date(string: "2021-08-26T20:33:17.651Z"))

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, "8:acs:recipientId")

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, "8:acs:senderId")
            default:
                XCTFail("Did not create ChatMessageEdited")
            }
        } catch {
            XCTFail("Failed to create ChatMessageEdited: \(error)")
        }
    }
    
    func test_createChatMessageEdited_withoutSenderDisplayName() {
        do {
            let payload = """
                {
                    "_eventId": 247,
                    "senderId": "8:acs:senderId",
                    "recipientId": "acs:recipientId",
                    "transactionId": "transactionId",
                    "groupId": "thread123",
                    "messageId": "123",
                    "collapseId": "collapseId",
                    "messageType": "Text",
                    "messageBody": "Hello!",
                    "senderDisplayName": "",
                    "clientMessageId": "",
                    "originalArrivalTime": "2021-08-26T20:30:09.593Z",
                    "priority": "",
                    "version": "456",
                    "edittime": "2021-08-26T20:33:17.651Z",
                    "composetime": "2021-08-26T20:30:09.593Z"
                }
            """

            let trouterRequest = TrouterRequestMock(
                id: 1,
                method: "POST",
                path: "",
                headers: [
                    "ms-cv": "abcd"
                ],
                body: payload
            )

            let result = try TrouterEventUtil.create(chatEvent: .chatMessageEdited, from: trouterRequest)
            
            switch result {
            case let .chatMessageEdited(event):
                XCTAssertEqual(event.id, "123")
                XCTAssertEqual(event.createdOn, Iso8601Date(string: "2021-08-26T20:30:09.593Z"))
                XCTAssertEqual(event.message, "Hello!")
                XCTAssertEqual(event.senderDisplayName, "")
                XCTAssertEqual(event.threadId, "thread123")
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, "456")
                XCTAssertEqual(event.editedOn, Iso8601Date(string: "2021-08-26T20:33:17.651Z"))

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, "8:acs:recipientId")

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, "8:acs:senderId")
            default:
                XCTFail("Did not create ChatMessageEdited")
            }
        } catch {
            XCTFail("Failed to create ChatMessageEdited: \(error)")
        }
    }
    
    func test_createChatMessageDeleted_withSenderDisplayName() {
        do {
            let payload = """
                {
                    "_eventId": 248,
                    "senderId": "8:acs:senderId",
                    "recipientId": "acs:recipientId",
                    "transactionId": "transactionId",
                    "groupId": "thread123",
                    "messageId": "123",
                    "collapseId": "collapseId",
                    "messageType": "Text",
                    "version": "456",
                    "composetime": "2021-08-26T20:30:09.593Z",
                    "deletetime": "2021-08-26T20:34:21.322Z",
                    "originalArrivalTime": "2021-08-26T20:30:09.593Z",
                    "clientMessageId": "",
                    "senderDisplayName": "SenderName"
                }
            """

            let trouterRequest = TrouterRequestMock(
                id: 1,
                method: "POST",
                path: "",
                headers: [
                    "ms-cv": "abcd"
                ],
                body: payload
            )

            let result = try TrouterEventUtil.create(chatEvent: .chatMessageDeleted, from: trouterRequest)
            
            switch result {
            case let .chatMessageDeleted(event):
                XCTAssertEqual(event.id, "123")
                XCTAssertEqual(event.createdOn, Iso8601Date(string: "2021-08-26T20:30:09.593Z"))
                XCTAssertEqual(event.senderDisplayName, "SenderName")
                XCTAssertEqual(event.threadId, "thread123")
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, "456")
                XCTAssertEqual(event.deletedOn, Iso8601Date(string: "2021-08-26T20:34:21.322Z"))

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, "8:acs:recipientId")

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, "8:acs:senderId")
            default:
                XCTFail("Did not create ChatMessageDeleted")
            }
        } catch {
            XCTFail("Failed to create ChatMessageDeleted: \(error)")
        }
    }

    func test_createChatMessageDeleted_withoutSenderDisplayName() {
        do {
            let payload = """
                {
                    "_eventId": 248,
                    "senderId": "8:acs:senderId",
                    "recipientId": "acs:recipientId",
                    "transactionId": "transactionId",
                    "groupId": "thread123",
                    "messageId": "123",
                    "collapseId": "collapseId",
                    "messageType": "Text",
                    "version": "456",
                    "composetime": "2021-08-26T20:30:09.593Z",
                    "deletetime": "2021-08-26T20:34:21.322Z",
                    "originalArrivalTime": "2021-08-26T20:30:09.593Z",
                    "clientMessageId": "",
                    "senderDisplayName": ""
                }
            """

            let trouterRequest = TrouterRequestMock(
                id: 1,
                method: "POST",
                path: "",
                headers: [
                    "ms-cv": "abcd"
                ],
                body: payload
            )

            let result = try TrouterEventUtil.create(chatEvent: .chatMessageDeleted, from: trouterRequest)
            
            switch result {
            case let .chatMessageDeleted(event):
                XCTAssertEqual(event.id, "123")
                XCTAssertEqual(event.createdOn, Iso8601Date(string: "2021-08-26T20:30:09.593Z"))
                XCTAssertEqual(event.senderDisplayName, "")
                XCTAssertEqual(event.threadId, "thread123")
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, "456")
                XCTAssertEqual(event.deletedOn, Iso8601Date(string: "2021-08-26T20:34:21.322Z"))

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, "8:acs:recipientId")

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, "8:acs:senderId")
            default:
                XCTFail("Did not create ChatMessageDeleted")
            }
        } catch {
            XCTFail("Failed to create ChatMessageDeleted: \(error)")
        }
    }
    
    func test_typingIndicatorReceived() {
        do {
            let payload = """
                {
                    "_eventId": 245,
                    "senderId": "8:acs:senderId",
                    "recipientId": "acs:recipientId",
                    "transactionId": "transactionId",
                    "groupId": "thread123",
                    "messageId": "123",
                    "collapseId": "collapseId",
                    "messageType": "Control/Typing",
                    "senderDisplayName": "",
                    "originalArrivalTime": "2021-08-26T20:27:39.23Z",
                    "version": "456"
                }
            """

            let trouterRequest = TrouterRequestMock(
                id: 1,
                method: "POST",
                path: "",
                headers: [
                    "ms-cv": "abcd"
                ],
                body: payload
            )

            let result = try TrouterEventUtil.create(chatEvent: .typingIndicatorReceived, from: trouterRequest)
            
            switch result {
            case let .typingIndicatorReceived(event):
                XCTAssertEqual(event.receivedOn, Iso8601Date(string: "2021-08-26T20:27:39.23Z"))
                XCTAssertEqual(event.version, "456")
                XCTAssertEqual(event.threadId, "thread123")

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, "8:acs:recipientId")

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, "8:acs:senderId")
            default:
                XCTFail("Did not create TypingIndicatorReceived")
            }
        } catch {
            XCTFail("Failed to create TypingIndicatorReceived: \(error)")
        }
    }
    
    func test_readReceiptReceived() {
        do {
            let iso8601Date = Iso8601Date(string: "2021-08-26T20:27:39Z")
            guard let date = iso8601Date?.value else {
                XCTFail("Failure creating date.")
                return
            }
            let epochTimeMs = Int(date.timeIntervalSince1970 * 1000)

            let messageBody = "\"{\\\"user\\\":\\\"8:acs:senderId\\\",\\\"consumptionhorizon\\\":\\\"1630009809593;\(epochTimeMs);0\\\",\\\"messageVisibilityTime\\\":1630009804562,\\\"version\\\":\\\"1630009817985.94\\\"}\""

            let payload = """
                {
                    "_eventId": 246,
                    "senderId": "8:acs:senderId",
                    "recipientId": "acs:recipientId",
                    "transactionId": "transactionId",
                    "groupId": "thread123",
                    "messageId": "123",
                    "collapseId": "collapseId",
                    "messageType": "ThreadActivity/MemberConsumptionHorizonUpdate",
                    "messageBody": \(messageBody),
                    "clientMessageId": "0",
                    "senderDisplayName": ""
                }
            """

            let trouterRequest = TrouterRequestMock(
                id: 1,
                method: "POST",
                path: "",
                headers: [
                    "ms-cv": "abcd"
                ],
                body: payload
            )

            let result = try TrouterEventUtil.create(chatEvent: .readReceiptReceived, from: trouterRequest)
            
            switch result {
            case let .readReceiptReceived(event):
                XCTAssertEqual(event.chatMessageId, "123")
                XCTAssertEqual(event.threadId, "thread123")
                XCTAssertEqual(event.readOn, iso8601Date)

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, "8:acs:recipientId")

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, "8:acs:senderId")
            default:
                XCTFail("Did not create ReadReceiptReceived")
            }
        } catch {
            XCTFail("Failed to create ReadReceiptReceived: \(error)")
        }
    }

    func test_chatThreadCreated_withDisplayName() {
        do {
            let payload = """
                {
                    "_eventId": 257,
                    "senderId": "8:acs:senderId",
                    "createdBy": "{\"displayName\":\"Bob\",\"participantId\":\"8:acs:senderId\"}",
                    "recipientId": "acs:recipientId",
                    "transactionId": "transactionId",
                    "groupId": "",
                    "threadId": "thread123",
                    "collapseId": "",
                    "createTime": "2021-08-31T17:11:29.01Z",
                    "members": "[{\"displayName\":\"Bob\",\"participantId\":\"8:acs:senderId\"},{\"displayName\":\"Alice\",\"participantId\":\"8:acs:recipientId\"}]",
                    "properties": "{\"topic\":\"Lunch Thread\",\"partnerName\":\"spool\",\"isMigrated\":true}",
                    "threadType": "chat",
                    "version": "456"
                }
            """

            let trouterRequest = TrouterRequestMock(
                id: 1,
                method: "POST",
                path: "",
                headers: [
                    "ms-cv": "abcd"
                ],
                body: payload
            )

            let result = try TrouterEventUtil.create(chatEvent: .chatThreadCreated, from: trouterRequest)
            
            switch result {
            case let .chatThreadCreated(event):
                XCTAssertEqual(event.createdOn, Iso8601Date(string: "2021-08-31T17:11:29.01Z"))
                XCTAssertEqual(event.threadId, "thread123")
                XCTAssertEqual(event.version, "456")
                XCTAssertEqual(event.createdBy?.displayName, "Bob")
                
                let createdBy = event.createdBy?.id as! CommunicationUserIdentifier
                XCTAssertEqual(createdBy.identifier, "8:acs:senderId")
                
                // participants + properties
            default:
                XCTFail("Did not create ChatThreadCreated")
            }
        } catch {
            XCTFail("Failed to create ChatThreadCreated: \(error)")
        }
    }

}
