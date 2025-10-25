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

@testable import AzureCommunicationChat
import AzureCommunicationCommon
import AzureCore
import Trouter
import XCTest

// swiftlint:disable line_length type_body_length force_cast file_length

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
    let senderId = "8:acs:senderId"
    let payloadRecipientId = "acs:recipientId"
    let payloadRecipientMri = "8:acs:recipientId"
    let expectedRecipientId = "8:acs:recipientId"
    let messageId = "123"
    let threadId = "thread123"
    let messageContent = "Hello!"
    let senderDisplayName = "Sender Name"
    let emptyDisplayName = ""
    let dateString = "2021-08-26T20:25:58.742Z"
    let version = "456"

    func test_createChatMessageReceivedEvent_withSenderDisplayName() {
        do {
            let payload =
                "{\"eventId\": 200,\"senderId\": \"\(senderId)\",\"recipientId\": \"\(payloadRecipientId)\",\"recipientMri\": \"\(payloadRecipientMri)\",\"transactionId\": \"transactionId\",\"groupId\": \"\(threadId)\",\"messageId\": \"\(messageId)\",\"collapseId\":\"collapseId\",\"messageType\": \"\(ChatMessageType.text.requestString)\",\"messageBody\": \"\(messageContent)\",\"senderDisplayName\": \"\(senderDisplayName)\",\"clientMessageId\": \"\",\"originalArrivalTime\": \"\(dateString)\",\"priority\": \"\",\"version\": \"\(version)\",\"acsChatMessageMetadata\": \"null\"}"

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
                XCTAssertEqual(event.id, messageId)
                XCTAssertEqual(event.createdOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.message, messageContent)
                XCTAssertEqual(event.senderDisplayName, senderDisplayName)
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, version)

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, expectedRecipientId)

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, senderId)
            default:
                XCTFail("Did not create ChatMessageReceivedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatMessageReceivedEvent: \(error)")
        }
    }

    func test_createChatMessageReceivedEvent_withoutDisplayNameOrMetdata() {
        do {
            let payload =
                "{\"eventId\": 200,\"senderId\": \"\(senderId)\",\"recipientId\": \"\(payloadRecipientId)\",\"recipientMri\": \"\(payloadRecipientMri)\",\"transactionId\": \"transactionId\",\"groupId\": \"\(threadId)\",\"messageId\": \"\(messageId)\",\"collapseId\":\"collapseId\",\"messageType\": \"\(ChatMessageType.text.requestString)\",\"messageBody\": \"\(messageContent)\",\"senderDisplayName\": \"\(emptyDisplayName)\",\"clientMessageId\": \"\",\"originalArrivalTime\": \"\(dateString)\",\"priority\": \"\",\"version\": \"\(version)\",\"acsChatMessageMetadata\": \"null\"}"

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
                XCTAssertEqual(event.id, messageId)
                XCTAssertEqual(event.createdOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.message, messageContent)
                XCTAssertEqual(event.senderDisplayName, emptyDisplayName)
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, version)

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, expectedRecipientId)

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, senderId)
            default:
                XCTFail("Did not create ChatMessageReceivedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatMessageReceivedEvent: \(error)")
        }
    }

    func test_createChatMessageReceivedEvent_withMetadata() {
        do {
            let metadataKey = "testKey"
            let metadataValue = "testValue"
            let payload =
                "{\"eventId\": 200,\"senderId\": \"\(senderId)\",\"recipientId\": \"\(payloadRecipientId)\",\"recipientMri\": \"\(payloadRecipientMri)\",\"transactionId\": \"transactionId\",\"groupId\": \"\(threadId)\",\"messageId\": \"\(messageId)\",\"collapseId\":\"collapseId\",\"messageType\": \"\(ChatMessageType.text.requestString)\",\"messageBody\": \"\(messageContent)\",\"senderDisplayName\": \"\(emptyDisplayName)\",\"clientMessageId\": \"\",\"originalArrivalTime\": \"\(dateString)\",\"priority\": \"\",\"version\": \"\(version)\",\"acsChatMessageMetadata\": \"{\\\"\(metadataKey)\\\":\\\"\(metadataValue)\\\"}\"}"

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
                XCTAssertEqual(event.id, messageId)
                XCTAssertEqual(event.createdOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.message, messageContent)
                XCTAssertEqual(event.senderDisplayName, emptyDisplayName)
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, version)
                XCTAssertNotNil(event.metadata)
                XCTAssertEqual(event.metadata?[metadataKey], metadataValue)

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, expectedRecipientId)

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, senderId)
            default:
                XCTFail("Did not create ChatMessageReceivedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatMessageReceivedEvent: \(error)")
        }
    }

    func test_createChatMessageEditedEvent_withSenderDisplayName() {
        do {
            let editTime = "2021-08-26T20:33:17.651Z"
            let payload = """
                {
                    "eventId": 247,
                    "senderId": "\(senderId)",
                    "recipientId": "\(payloadRecipientId)",
                    "recipientMri": "\(payloadRecipientMri)",
                    "transactionId": "transactionId",
                    "groupId": "\(threadId)",
                    "messageId": "\(messageId)",
                    "collapseId": "collapseId",
                    "messageType": "\(ChatMessageType.text.requestString)",
                    "messageBody": "\(messageContent)",
                    "senderDisplayName": "\(senderDisplayName)",
                    "clientMessageId": "",
                    "originalArrivalTime": "\(dateString)",
                    "priority": "",
                    "version": "\(version)",
                    "edittime": "\(editTime)",
                    "composetime": "2021-08-26T20:30:09.593Z",
                    "acsChatMessageMetadata": "{}"
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
                XCTAssertEqual(event.id, messageId)
                XCTAssertEqual(event.createdOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.message, messageContent)
                XCTAssertEqual(event.senderDisplayName, senderDisplayName)
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, version)
                XCTAssertEqual(event.editedOn, Iso8601Date(string: editTime))
                XCTAssertEqual(event.metadata, [:])

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, expectedRecipientId)

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, senderId)
            default:
                XCTFail("Did not create ChatMessageEditedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatMessageEditedEvent: \(error)")
        }
    }

    func test_createChatMessageEditedEvent_withoutSenderDisplayNameOrMetadata() {
        do {
            let editTime = "2021-08-26T20:33:17.651Z"
            let payload =
                "{\"eventId\": 247,\"senderId\": \"\(senderId)\",\"recipientId\": \"\(payloadRecipientId)\",\"recipientMri\": \"\(payloadRecipientMri)\",\"transactionId\": \"transactionId\",\"groupId\": \"\(threadId)\",\"messageId\": \"\(messageId)\",\"collapseId\":\"collapseId\",\"messageType\": \"\(ChatMessageType.text.requestString)\",\"messageBody\": \"\(messageContent)\",\"senderDisplayName\": \"\(emptyDisplayName)\",\"clientMessageId\": \"\",\"originalArrivalTime\": \"\(dateString)\",\"priority\": \"\",\"version\": \"\(version)\",\"edittime\": \"\(editTime)\",\"composetime\": \"2021-09-03T17:35:28.663Z\",\"acsChatMessageMetadata\": \"{}\"}"

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
                XCTAssertEqual(event.id, messageId)
                XCTAssertEqual(event.createdOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.message, messageContent)
                XCTAssertEqual(event.senderDisplayName, emptyDisplayName)
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, version)
                XCTAssertEqual(event.editedOn, Iso8601Date(string: editTime))
                XCTAssertEqual(event.metadata, [:])

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, expectedRecipientId)

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, senderId)
            default:
                XCTFail("Did not create ChatMessageEditedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatMessageEditedEvent: \(error)")
        }
    }

    func test_createChatMessageEditedEvent_withMetadata() {
        do {
            let metadataKey = "testKey"
            let metadataValue = "testValue"
            let editTime = "2021-08-26T20:33:17.651Z"
            let payload =
                "{\"eventId\": 247,\"senderId\": \"\(senderId)\",\"recipientId\": \"\(payloadRecipientId)\",\"recipientMri\": \"\(payloadRecipientMri)\",\"transactionId\": \"transactionId\",\"groupId\": \"\(threadId)\",\"messageId\": \"\(messageId)\",\"collapseId\":\"collapseId\",\"messageType\": \"\(ChatMessageType.text.requestString)\",\"messageBody\": \"\(messageContent)\",\"senderDisplayName\": \"\(emptyDisplayName)\",\"clientMessageId\": \"\",\"originalArrivalTime\": \"\(dateString)\",\"priority\": \"\",\"version\": \"\(version)\",\"edittime\": \"\(editTime)\",\"composetime\": \"2021-09-03T17:18:05.114Z\",\"acsChatMessageMetadata\": \"{\\\"\(metadataKey)\\\":\\\"\(metadataValue)\\\"}\"}"

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
                XCTAssertEqual(event.id, messageId)
                XCTAssertEqual(event.createdOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.message, messageContent)
                XCTAssertEqual(event.senderDisplayName, emptyDisplayName)
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, version)
                XCTAssertEqual(event.editedOn, Iso8601Date(string: editTime))
                XCTAssertEqual(event.metadata?[metadataKey], metadataValue)

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, expectedRecipientId)

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, senderId)
            default:
                XCTFail("Did not create ChatMessageEditedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatMessageEditedEvent: \(error)")
        }
    }

    func test_createChatMessageDeletedEvent_withSenderDisplayName() {
        do {
            let deleteTime = "2021-08-26T20:34:21.322Z"
            let payload = """
                {
                    "eventId": 248,
                    "senderId": "\(senderId)",
                    "recipientId": "\(payloadRecipientId)",
                    "recipientMri": "\(payloadRecipientMri)",
                    "transactionId": "transactionId",
                    "groupId": "\(threadId)",
                    "messageId": "\(messageId)",
                    "collapseId": "collapseId",
                    "messageType": "\(ChatMessageType.text.requestString)",
                    "version": "\(version)",
                    "composetime": "2021-08-26T20:30:09.593Z",
                    "deletetime": "\(deleteTime)",
                    "originalArrivalTime": "\(dateString)",
                    "clientMessageId": "",
                    "senderDisplayName": "\(senderDisplayName)"
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
                XCTAssertEqual(event.id, messageId)
                XCTAssertEqual(event.createdOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.senderDisplayName, senderDisplayName)
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, version)
                XCTAssertEqual(event.deletedOn, Iso8601Date(string: deleteTime))

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, expectedRecipientId)

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, senderId)
            default:
                XCTFail("Did not create ChatMessageDeletedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatMessageDeletedEvent: \(error)")
        }
    }

    func test_createChatMessageDeletedEvent_withoutSenderDisplayName() {
        do {
            let deleteTime = "2021-08-26T20:34:21.322Z"
            let payload = """
                {
                    "eventId": 248,
                    "senderId": "\(senderId)",
                    "recipientId": "\(payloadRecipientId)",
                    "recipientMri": "\(payloadRecipientMri)",
                    "transactionId": "transactionId",
                    "groupId": "\(threadId)",
                    "messageId": "\(messageId)",
                    "collapseId": "collapseId",
                    "messageType": "\(ChatMessageType.text.requestString)",
                    "version": "\(version)",
                    "composetime": "2021-08-26T20:30:09.593Z",
                    "deletetime": "\(deleteTime)",
                    "originalArrivalTime": "\(dateString)",
                    "clientMessageId": "",
                    "senderDisplayName": "\(emptyDisplayName)"
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
                XCTAssertEqual(event.id, messageId)
                XCTAssertEqual(event.createdOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.senderDisplayName, emptyDisplayName)
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.type, .text)
                XCTAssertEqual(event.version, version)
                XCTAssertEqual(event.deletedOn, Iso8601Date(string: deleteTime))

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, expectedRecipientId)

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, senderId)
            default:
                XCTFail("Did not create ChatMessageDeletedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatMessageDeletedEvent: \(error)")
        }
    }

    func test_typingIndicatorReceivedEvent() {
        do {
            let payload = """
                {
                    "eventId": 245,
                    "senderId": "\(senderId)",
                    "recipientId": "\(payloadRecipientId)",
                    "recipientMri": "\(payloadRecipientMri)",
                    "transactionId": "transactionId",
                    "groupId": "\(threadId)",
                    "messageId": "\(messageId)",
                    "collapseId": "collapseId",
                    "messageType": "Control/Typing",
                    "senderDisplayName": "",
                    "originalArrivalTime": "\(dateString)",
                    "version": "\(version)"
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
                XCTAssertEqual(event.receivedOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.version, version)
                XCTAssertEqual(event.threadId, threadId)

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, expectedRecipientId)

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, senderId)
            default:
                XCTFail("Did not create TypingIndicatorReceivedEvent")
            }
        } catch {
            XCTFail("Failed to create TypingIndicatorReceivedEvent: \(error)")
        }
    }

    func test_readReceiptReceivedEvent() {
        do {
            let iso8601Date = Iso8601Date(string: dateString)
            guard let date = iso8601Date?.value else {
                XCTFail("Failure creating date.")
                return
            }
            let epochTimeMs = Double(date.timeIntervalSince1970 * 1000)

            let messageBody =
                "\"{\\\"user\\\":\\\"\(senderId)\\\",\\\"consumptionhorizon\\\":\\\"1630009809593;\(epochTimeMs);0\\\",\\\"messageVisibilityTime\\\":1630009804562,\\\"version\\\":\\\"\(version)\\\"}\""

            let payload = """
                {
                    "eventId": 246,
                    "senderId": "\(senderId)",
                    "recipientId": "\(payloadRecipientId)",
                    "recipientMri": "\(payloadRecipientMri)",
                    "transactionId": "transactionId",
                    "groupId": "\(threadId)",
                    "messageId": "\(messageId)",
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
                XCTAssertEqual(event.chatMessageId, messageId)
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.readOn, iso8601Date)

                let recipient = event.recipient as! CommunicationUserIdentifier
                XCTAssertEqual(recipient.identifier, expectedRecipientId)

                let sender = event.sender as! CommunicationUserIdentifier
                XCTAssertEqual(sender.identifier, senderId)
            default:
                XCTFail("Did not create ReadReceiptReceivedEvent")
            }
        } catch {
            XCTFail("Failed to create ReadReceiptReceivedEvent: \(error)")
        }
    }

    func test_chatThreadCreatedEvent_withDisplayName() {
        do {
            let createdByDisplayName = "Creator Name"
            let createdById = "8:acs:creatorId"
            let createdBy =
                "\"{\\\"displayName\\\":\\\"\(createdByDisplayName)\\\",\\\"participantId\\\":\\\"\(createdById)\\\"}\""

            let userDisplayName = "Participant Name"
            let userId = "8:acs:participantId"

            let members =
                "\"[{\\\"displayName\\\":\\\"\(createdByDisplayName)\\\",\\\"participantId\\\":\\\"\(createdById)\\\"},{\\\"displayName\\\":\\\"\(userDisplayName)\\\",\\\"participantId\\\":\\\"\(userId)\\\"}]\""

            let topic = "Topic"
            let properties =
                "\"{\\\"topic\\\":\\\"\(topic)\\\",\\\"partnerName\\\":\\\"partner\\\",\\\"isMigrated\\\":true}\""

            let payload = """
                {
                    "eventId": 257,
                    "senderId": "\(senderId)",
                    "createdBy": \(createdBy),
                    "recipientId": "\(userId)",
                    "transactionId": "transactionId",
                    "groupId": "",
                    "threadId": "\(threadId)",
                    "collapseId": "",
                    "createTime": "\(dateString)",
                    "members": \(members),
                    "properties": \(properties),
                    "threadType": "chat",
                    "version": "\(version)"
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
                XCTAssertEqual(event.createdOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.version, version)
                XCTAssertEqual(event.createdBy?.displayName, createdByDisplayName)

                let createdBy = event.createdBy?.id as! CommunicationUserIdentifier
                XCTAssertEqual(createdBy.identifier, createdById)

                let participant1 = event.participants?[0]
                XCTAssertEqual(participant1?.displayName, createdByDisplayName)
                let participant1Id = participant1?.id as! CommunicationUserIdentifier
                XCTAssertEqual(participant1Id.identifier, createdById)

                let participant2 = event.participants?[1]
                XCTAssertEqual(participant2?.displayName, userDisplayName)
                let participant2Id = participant2?.id as! CommunicationUserIdentifier
                XCTAssertEqual(participant2Id.identifier, userId)

                XCTAssertEqual(event.properties?.topic, topic)
            default:
                XCTFail("Did not create ChatThreadCreatedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatThreadCreatedEvent: \(error)")
        }
    }

    func test_chatThreadCreatedEvent_withoutDisplayName() {
        do {
            let createdById = "8:acs:creatorId"
            let createdBy = "\"{\\\"displayName\\\":null,\\\"participantId\\\":\\\"\(createdById)\\\"}\""

            let userId = "8:acs:participantId"

            let members =
                "\"[{\\\"displayName\\\":null,\\\"participantId\\\":\\\"\(createdById)\\\"},{\\\"displayName\\\":null,\\\"participantId\\\":\\\"\(userId)\\\"}]\""

            let topic = "Topic"
            let properties =
                "\"{\\\"topic\\\":\\\"\(topic)\\\",\\\"partnerName\\\":\\\"partner\\\",\\\"isMigrated\\\":true}\""

            let payload = """
                {
                    "eventId": 257,
                    "senderId": "\(senderId)",
                    "createdBy": \(createdBy),
                    "recipientId": "\(userId)",
                    "transactionId": "transactionId",
                    "groupId": "",
                    "threadId": "\(threadId)",
                    "collapseId": "",
                    "createTime": "\(dateString)",
                    "members": \(members),
                    "properties": \(properties),
                    "threadType": "chat",
                    "version": "\(version)"
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
                XCTAssertEqual(event.createdOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.version, version)
                XCTAssertEqual(event.createdBy?.displayName, nil)

                let createdBy = event.createdBy?.id as! CommunicationUserIdentifier
                XCTAssertEqual(createdBy.identifier, createdById)

                let participant1 = event.participants?[0]
                XCTAssertEqual(participant1?.displayName, nil)
                let participant1Id = participant1?.id as! CommunicationUserIdentifier
                XCTAssertEqual(participant1Id.identifier, createdById)

                let participant2 = event.participants?[1]
                XCTAssertEqual(participant2?.displayName, nil)
                let participant2Id = participant2?.id as! CommunicationUserIdentifier
                XCTAssertEqual(participant2Id.identifier, userId)

                XCTAssertEqual(event.properties?.topic, topic)
            default:
                XCTFail("Did not create ChatThreadCreatedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatThreadCreatedEvent: \(error)")
        }
    }

    func test_chatThreadPropertiesUpdatedEvent_withDisplayName() {
        do {
            let editedBy =
                "\"{\\\"displayName\\\":\\\"\(senderDisplayName)\\\",\\\"participantId\\\":\\\"\(senderId)\\\"}\""
            let editTime = "2021-08-26T20:35:17.9882388Z"
            let topic = "Topic"
            let properties =
                "\"{\\\"topic\\\":\\\"\(topic)\\\",\\\"partnerName\\\":\\\"spool\\\",\\\"isMigrated\\\":true}\""

            let payload = """
                {
                    "eventId": 258,
                    "senderId": "\(senderId)",
                    "editedBy": \(editedBy),
                    "recipientId": "\(payloadRecipientId)",
                    "transactionId": "transactionId",
                    "groupId": "",
                    "threadId": "\(threadId)",
                    "collapseId": "",
                    "createTime": "\(dateString)",
                    "editTime": "\(editTime)",
                    "properties": \(properties),
                    "threadType": "chat",
                    "version": "\(version)"
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

            let result = try TrouterEventUtil.create(chatEvent: .chatThreadPropertiesUpdated, from: trouterRequest)

            switch result {
            case let .chatThreadPropertiesUpdated(event):
                XCTAssertEqual(event.updatedOn, Iso8601Date(string: editTime))
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.version, version)

                let updatedById = event.updatedBy?.id as! CommunicationUserIdentifier
                XCTAssertEqual(event.updatedBy?.displayName, senderDisplayName)
                XCTAssertEqual(updatedById.identifier, senderId)

                XCTAssertEqual(event.properties?.topic, topic)
            default:
                XCTFail("Did not create ChatThreadPropertiesUpdatedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatThreadPropertiesUpdatedEvent: \(error)")
        }
    }

    func test_chatThreadPropertiesUpdatedEvent_withoutDisplayName() {
        do {
            let editedBy = "\"{\\\"displayName\\\":null,\\\"participantId\\\":\\\"\(senderId)\\\"}\""
            let editTime = "2021-08-26T20:35:17.9882388Z"
            let topic = "Topic"
            let properties =
                "\"{\\\"topic\\\":\\\"\(topic)\\\",\\\"partnerName\\\":\\\"spool\\\",\\\"isMigrated\\\":true}\""

            let payload = """
                {
                    "eventId": 258,
                    "senderId": "\(senderId)",
                    "editedBy": \(editedBy),
                    "recipientId": "\(payloadRecipientId)",
                    "transactionId": "transactionId",
                    "groupId": "",
                    "threadId": "\(threadId)",
                    "collapseId": "",
                    "createTime": "\(dateString)",
                    "editTime": "\(editTime)",
                    "properties": \(properties),
                    "threadType": "chat",
                    "version": "\(version)"
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

            let result = try TrouterEventUtil.create(chatEvent: .chatThreadPropertiesUpdated, from: trouterRequest)

            switch result {
            case let .chatThreadPropertiesUpdated(event):
                XCTAssertEqual(event.updatedOn, Iso8601Date(string: editTime))
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.version, version)

                let updatedById = event.updatedBy?.id as! CommunicationUserIdentifier
                XCTAssertEqual(event.updatedBy?.displayName, nil)
                XCTAssertEqual(updatedById.identifier, senderId)

                XCTAssertEqual(event.properties?.topic, topic)
            default:
                XCTFail("Did not create ChatThreadPropertiesUpdatedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatThreadPropertiesUpdatedEvent: \(error)")
        }
    }

    func test_chatThreadDeletedEvent_withDisplayName() {
        do {
            let deletedBy =
                "\"{\\\"displayName\\\":\\\"\(senderDisplayName)\\\",\\\"participantId\\\":\\\"\(senderId)\\\"}\""
            let deleteTime = "2021-08-26T20:35:17.9882388Z"

            let payload = """
                {
                    "eventId": 259,
                    "senderId": "\(senderId)",
                    "deletedBy": \(deletedBy),
                    "recipientId": "\(payloadRecipientId)",
                    "transactionId": "transactionId",
                    "groupId": "",
                    "threadId": "\(threadId)",
                    "collapseId": "",
                    "createTime": "\(dateString)",
                    "deleteTime": "\(deleteTime)",
                    "threadType": "chat",
                    "version": "\(version)"
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

            let result = try TrouterEventUtil.create(chatEvent: .chatThreadDeleted, from: trouterRequest)

            switch result {
            case let .chatThreadDeleted(event):
                XCTAssertEqual(event.deletedOn, Iso8601Date(string: deleteTime))
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.version, version)

                let deletedById = event.deletedBy?.id as! CommunicationUserIdentifier
                XCTAssertEqual(event.deletedBy?.displayName, senderDisplayName)
                XCTAssertEqual(deletedById.identifier, senderId)
            default:
                XCTFail("Did not create ChatThreadDeleted")
            }
        } catch {
            XCTFail("Failed to create ChatThreadDeleted: \(error)")
        }
    }

    func test_chatThreadDeletedEvent_withoutDisplayName() {
        do {
            let deletedBy = "\"{\\\"displayName\\\":null,\\\"participantId\\\":\\\"\(senderId)\\\"}\""
            let deleteTime = "2021-08-26T20:35:17.9882388Z"

            let payload = """
                {
                    "eventId": 259,
                    "senderId": "\(senderId)",
                    "deletedBy": \(deletedBy),
                    "recipientId": "\(payloadRecipientId)",
                    "transactionId": "transactionId",
                    "groupId": "",
                    "threadId": "\(threadId)",
                    "collapseId": "",
                    "createTime": "\(dateString)",
                    "deleteTime": "\(deleteTime)",
                    "threadType": "chat",
                    "version": "\(version)"
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

            let result = try TrouterEventUtil.create(chatEvent: .chatThreadDeleted, from: trouterRequest)

            switch result {
            case let .chatThreadDeleted(event):
                XCTAssertEqual(event.deletedOn, Iso8601Date(string: deleteTime))
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.version, version)

                let deletedById = event.deletedBy?.id as! CommunicationUserIdentifier
                XCTAssertEqual(event.deletedBy?.displayName, nil)
                XCTAssertEqual(deletedById.identifier, senderId)
            default:
                XCTFail("Did not create ChatThreadDeletedEvent")
            }
        } catch {
            XCTFail("Failed to create ChatThreadDeletedEvent: \(error)")
        }
    }

    func test_createParticipantsAdded_withDisplayName() {
        do {
            let userDisplayName = "User Name"
            let userId = "8:acs:user"
            let participantsAdded =
                "\"[{\\\"shareHistoryTime\\\":1604055050000,\\\"displayName\\\":\\\"\(userDisplayName)\\\",\\\"participantId\\\":\\\"\(userId)\\\"}]\""
            let addedBy =
                "\"{\\\"displayName\\\":\\\"\(senderDisplayName)\\\",\\\"participantId\\\":\\\"\(senderId)\\\"}\""

            let payload = """
                {
                    "eventId": 260,
                    "senderId": "\(senderId)",
                    "addedBy": \(addedBy),
                    "recipientId": "\(payloadRecipientId)",
                    "transactionId": "transactionId",
                    "groupId": "",
                    "threadId": "\(threadId)",
                    "collapseId": "",
                    "createTime": "2021-08-26T20:30:04.562Z",
                    "time": "\(dateString)",
                    "participantsAdded": \(participantsAdded),
                    "version": "\(version)"
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

            let result = try TrouterEventUtil.create(chatEvent: .participantsAdded, from: trouterRequest)

            switch result {
            case let .participantsAdded(event):
                XCTAssertEqual(event.addedOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.version, version)

                let addedBy = event.addedBy?.id as! CommunicationUserIdentifier
                XCTAssertEqual(event.addedBy?.displayName, senderDisplayName)
                XCTAssertEqual(addedBy.identifier, senderId)

                let participant = event.participantsAdded?[0]
                let participantId = participant?.id as! CommunicationUserIdentifier
                XCTAssertEqual(participant?.displayName, userDisplayName)
                XCTAssertEqual(participantId.identifier, userId)
            default:
                XCTFail("Did not create ParticipantsAddedEvent")
            }
        } catch {
            XCTFail("Failed to create ParticipantsAddedEvent: \(error)")
        }
    }

    func test_createParticipantsAdded_withoutDisplayName() {
        do {
            let userId = "8:acs:user"
            let participantsAdded =
                "\"[{\\\"shareHistoryTime\\\":1604055050000,\\\"displayName\\\":null,\\\"participantId\\\":\\\"\(userId)\\\"}]\""
            let addedBy = "\"{\\\"displayName\\\":null,\\\"participantId\\\":\\\"\(senderId)\\\"}\""

            let payload = """
                {
                    "eventId": 260,
                    "senderId": "\(senderId)",
                    "addedBy": \(addedBy),
                    "recipientId": "\(payloadRecipientId)",
                    "transactionId": "transactionId",
                    "groupId": "",
                    "threadId": "\(threadId)",
                    "collapseId": "",
                    "createTime": "2021-08-26T20:30:04.562Z",
                    "time": "\(dateString)",
                    "participantsAdded": \(participantsAdded),
                    "version": "\(version)"
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

            let result = try TrouterEventUtil.create(chatEvent: .participantsAdded, from: trouterRequest)

            switch result {
            case let .participantsAdded(event):
                XCTAssertEqual(event.addedOn, Iso8601Date(string: dateString))
                XCTAssertEqual(event.threadId, threadId)
                XCTAssertEqual(event.version, version)

                let addedBy = event.addedBy?.id as! CommunicationUserIdentifier
                XCTAssertEqual(event.addedBy?.displayName, nil)
                XCTAssertEqual(addedBy.identifier, senderId)

                let participant = event.participantsAdded?[0]
                let participantId = participant?.id as! CommunicationUserIdentifier
                XCTAssertEqual(participant?.displayName, nil)
                XCTAssertEqual(participantId.identifier, userId)
            default:
                XCTFail("Did not create ParticipantsAddedEvent")
            }
        } catch {
            XCTFail("Failed to create ParticipantsAddedEvent: \(error)")
        }
    }

    func test_getCommunicationIdentifier_withAcsGcchUserRawId() {
        let userId = "8:gcch-acs:user"
        let result = createCommunicationIdentifier(fromRawId: userId)
        XCTAssertTrue(result is CommunicationUserIdentifier)
        XCTAssertEqual(userId, (result as? CommunicationUserIdentifier)?.identifier)
    }

    func test_getCommunicationIdentifier_withAcsDodUserRawId() {
        let userId = "8:dod-acs:user"
        let result = createCommunicationIdentifier(fromRawId: userId)
        XCTAssertTrue(result is CommunicationUserIdentifier)
        XCTAssertEqual(userId, (result as? CommunicationUserIdentifier)?.identifier)
    }
}
