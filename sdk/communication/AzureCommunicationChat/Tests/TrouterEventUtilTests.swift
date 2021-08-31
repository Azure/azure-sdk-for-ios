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
                    "senderId": "senderId",
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

            // Mock TrouterRequest for ChatMessageReceived
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

                let recipient = event.recipient as! UnknownIdentifier
                XCTAssertEqual(recipient.identifier, "recipientId")

                let sender = event.sender as! UnknownIdentifier
                XCTAssertEqual(sender.identifier, "senderId")
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
                    "senderId": "senderId",
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

            // Mock TrouterRequest for ChatMessageReceived
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

                let recipient = event.recipient as! UnknownIdentifier
                XCTAssertEqual(recipient.identifier, "recipientId")

                let sender = event.sender as! UnknownIdentifier
                XCTAssertEqual(sender.identifier, "senderId")
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
                    "senderId": "senderId",
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

            // Mock TrouterRequest for ChatMessageReceived
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

                let recipient = event.recipient as! UnknownIdentifier
                XCTAssertEqual(recipient.identifier, "recipientId")

                let sender = event.sender as! UnknownIdentifier
                XCTAssertEqual(sender.identifier, "senderId")
            default:
                XCTFail("Did not create ChatMessageEdited")
            }
        } catch {
            XCTFail("Failed to create ChatMessageEdited: \(error)")
        }
    }

}
