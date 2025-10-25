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

import AzureCommunicationChat
import AzureCommunicationCommon
import AzureCore
import OHHTTPStubs.Swift
import XCTest

// swiftlint:disable all
class ChatThreadClientUnitTests: XCTestCase {
    private var chatClient: ChatClient!
    private var chatThreadClient: ChatThreadClient!

    private let participantId = "test_participant_id"
    private let participantName = "test_participant_name"
    private let threadId = "test_thread_id"
    private let topic = "test topic"
    private let messageId = "test_message_id"

    private let settings = TestSettings()

    override func setUpWithError() throws {
        let endpoint = settings.endpoint
        let token = settings.token
        let credential = try CommunicationTokenCredential(token: token)
        let options = AzureCommunicationChatClientOptions()
        chatClient = try ChatClient(endpoint: endpoint, credential: credential, withOptions: options)
        chatThreadClient = try chatClient.createClient(forThread: threadId)
    }

    func test_UpdateThreadTopic_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodPATCH()) { _ in
            fixture(filePath: path, status: 204, headers: nil)
        }

        let expectation = self.expectation(description: "Update thread topic")

        chatThreadClient.update(topic: topic, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)

            case .failure:
                XCTFail("Unexpected failure happened in update thread topic")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Update thread topic timed out: \(error)")
            }
        }
    }

    func test_GetProperties_ReturnChatThreadProperties() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "GetThreadResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 200, headers: nil)
        }

        let expectation = self.expectation(description: "Get thread")

        chatThreadClient.getProperties { result, _ in
            switch result {
            case let .success(chatThread):
                XCTAssertEqual(chatThread.id, self.threadId)
                XCTAssertEqual(chatThread.topic, self.topic)
                guard let createdBy = chatThread.createdBy as? CommunicationUserIdentifier else {
                    XCTFail("Identifier is not of expected type.")
                    expectation.fulfill()
                    return
                }
                XCTAssertEqual(createdBy.identifier, self.participantId)

            case .failure:
                XCTFail()
            }

            expectation.fulfill()
        }
        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Get thread timed out: \(error)")
            }
        }
    }

    func test_GetProperties_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "Get thread")

        chatThreadClient.getProperties { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in get thread")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Get thread timed out: \(error)")
            }
        }
    }

    func test_UpdateThreadTopic_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPATCH()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "Update thread topic")

        chatThreadClient.update(topic: topic, completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in update thread topic")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Update thread topic timed out: \(error)")
            }
        }
    }

    func test_SendMessage_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "SendMessageResponse", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 201, headers: nil)
        }

        let messageRequest = SendChatMessageRequest(
            content: "Hello world!",
            senderDisplayName: "Leo"
        )

        let expectation = self.expectation(description: "Send message")

        chatThreadClient.send(message: messageRequest, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
                XCTAssertEqual(response.id, self.messageId)

            case .failure:
                XCTFail("Unexpected failure happened in send message")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }

    func test_SendMessage_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let messageRequest = SendChatMessageRequest(
            content: "Hello world!",
            senderDisplayName: "Leo"
        )

        let expectation = self.expectation(description: "Send message")

        chatThreadClient.send(message: messageRequest, completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in send message")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }

    func test_GetMessage_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "GetMessageResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 200, headers: nil)
        }

        let expectation = self.expectation(description: "Get message")

        chatThreadClient.get(message: messageId, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                guard let content = response.content else {
                    XCTFail("Failed to extract message content from response")
                    return
                }
                XCTAssertNotNil(response)
                XCTAssertEqual(response.id, self.messageId)
                XCTAssertEqual(content.message, "Hello World!")

            case .failure:
                XCTFail("Unexpected failure happened in get message")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Get message timed out: \(error)")
            }
        }
    }

    func test_GetMessage_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "Get message")

        chatThreadClient.get(message: messageId, completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in get message")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Get message timed out: \(error)")
            }
        }
    }

    func test_ListMessages_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "ListMessagesResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 200, headers: nil)
        }

        let expectation = self.expectation(description: "List messages")

        chatThreadClient.listMessages(completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
                response.nextItem { result in
                    switch result {
                    case let .success(message):
                        guard let content = message.content else {
                            XCTFail("Failed to extract message content from response")
                            return
                        }
                        XCTAssertEqual(message.id, self.messageId)
                        XCTAssertEqual(content.message, "Hello world!")
                        if let sender = message.sender as? CommunicationUserIdentifier {
                            XCTAssertEqual(sender.identifier, self.participantId)
                        }

                    case .failure:
                        XCTFail("Unexpected failure happened in list messages")
                    }
                }

            case .failure:
                XCTFail("Unexpected failure happened in list messages")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("List messages timed out: \(error)")
            }
        }
    }

    func test_ListMessages_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "List messages")

        chatThreadClient.listMessages(completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in list messages")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("List messages timed out: \(error)")
            }
        }
    }

    func test_UpdateMessage_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodPATCH()) { _ in
            fixture(filePath: path, status: 204, headers: nil)
        }

        let expectation = self.expectation(description: "Update message")

        let updatedMessage = UpdateChatMessageRequest(
            content: "update message",
            metadata: ["test": "metadata"]
        )

        chatThreadClient.update(message: messageId, parameters: updatedMessage, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)

            case .failure:
                XCTFail("Unexpected failure happened in update message")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Update message timed out: \(error)")
            }
        }
    }

    func test_UpdateMessage_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPATCH()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "Update message")

        chatThreadClient.update(topic: topic, completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in update message")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Update message timed out: \(error)")
            }
        }
    }

    func test_DeleteMessage_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodDELETE()) { _ in
            fixture(filePath: path, status: 204, headers: nil)
        }

        let expectation = self.expectation(description: "Delete message")

        chatThreadClient.delete(message: messageId, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)

            case .failure:
                XCTFail("Unexpected failure happened in delete message")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Delete message timed out: \(error)")
            }
        }
    }

    func test_DeleteMessage_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodDELETE()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "Delete message")

        chatThreadClient.delete(message: messageId, completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in delete message")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Delete message timed out: \(error)")
            }
        }
    }

    func test_ListParticipants_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "ListParticipantsResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 200, headers: nil)
        }

        let expectation = self.expectation(description: "List participants")

        chatThreadClient.listParticipants(completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
                response.nextItem { result in
                    switch result {
                    case let .success(participant):
                        guard let displayName = participant.displayName else {
                            XCTFail("Failed to extract senderDisplayName from response")
                            return
                        }
                        guard let user = participant.id as? CommunicationUserIdentifier else {
                            XCTFail("Identifier is not of expected type")
                            expectation.fulfill()
                            return
                        }
                        XCTAssertEqual(user.identifier, self.participantId)
                        XCTAssertEqual(displayName, self.participantName)

                    case .failure:
                        XCTFail("Unexpected failure happened in list participants")
                    }
                }

            case .failure:
                XCTFail("Unexpected failure happened in list participants")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("List participants timed out: \(error)")
            }
        }
    }

    func test_ListParticipants_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "List participants")

        chatThreadClient.listParticipants(completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in list participants")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("List participants timed out: \(error)")
            }
        }
    }

    func test_AddParticipant_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "AddParticipantResponse", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 201, headers: nil)
        }

        let expectation = self.expectation(description: "Add participant")

        let participant = ChatParticipant(
            id: CommunicationUserIdentifier(participantId),
            shareHistoryTime: Iso8601Date(string: "2016-04-13T00:00:00Z")!
        )

        chatThreadClient.add(participants: [participant], completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)

            case .failure:
                XCTFail("Unexpected failure happened in Add participant")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Add participant timed out: \(error)")
            }
        }
    }

    func test_AddParticipant_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "Add participant")

        let participant = ChatParticipant(
            id: CommunicationUserIdentifier(participantId),
            shareHistoryTime: Iso8601Date(string: "2016-04-13T00:00:00Z")!
        )

        chatThreadClient.add(participants: [participant], completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in add participant")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Add participant timed out: \(error)")
            }
        }
    }

    func test_RemoveParticipant_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 204, headers: nil)
        }

        let expectation = self.expectation(description: "Remove Participant")

        chatThreadClient.remove(
            participant: CommunicationUserIdentifier(participantId),
            completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    XCTAssertNotNil(response)

                case .failure:
                    XCTFail("Unexpected failure happened in remove participant")
                }

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Remove participant timed out: \(error)")
            }
        }
    }

    func test_RemoveParticipant_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "Remove Participant")

        chatThreadClient.remove(
            participant: CommunicationUserIdentifier(participantId),
            completionHandler: { result, _ in
                switch result {
                case .success:
                    XCTFail("Unexpected failure happened in remove participant")

                case let .failure(error):
                    XCTAssertNotNil(error)
                }

                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Remove participant timed out: \(error)")
            }
        }
    }

    func test_SendTypingNotification_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 200, headers: nil)
        }

        let expectation = self.expectation(description: "Send typing notification")

        chatThreadClient.sendTypingNotification(completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)

            case .failure:
                XCTFail("Unexpected failure happened in send typing notification")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Send typing notification timed out: \(error)")
            }
        }
    }

    func test_SendTypingNotification_WithDisplayName_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 200, headers: nil)
        }

        let expectation = self.expectation(description: "Send typing notification")

        chatThreadClient.sendTypingNotification(from: "Foo", completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)

            case .failure:
                XCTFail("Unexpected failure happened in send typing notification")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Send typing notification timed out: \(error)")
            }
        }
    }

    func test_SendTypingNotification_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "Send typing notification")

        chatThreadClient.sendTypingNotification(completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in send typing notification")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Send typing notification timed out: \(error)")
            }
        }
    }

    func test_SendReadReceipt_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 200, headers: nil)
        }

        let expectation = self.expectation(description: "Send read receipt")

        chatThreadClient.sendReadReceipt(forMessage: messageId, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)

            case .failure:
                XCTFail("Unexpected failure happened in send read receipt")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Send read receipt timed out: \(error)")
            }
        }
    }

    func test_SendReadReceipt_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "Send read receipt")

        chatThreadClient.sendReadReceipt(forMessage: messageId, completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in send read receipt")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Send read receipt timed out: \(error)")
            }
        }
    }

    func test_ListReadReceipts_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "ListReadReceiptResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 200, headers: nil)
        }

        let expectation = self.expectation(description: "List read receipts")

        chatThreadClient.listReadReceipts(completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
                response.nextItem { result in
                    switch result {
                    case let .success(readReceipt):
                        guard let sender = readReceipt.sender as? CommunicationUserIdentifier else {
                            XCTFail("Identifier is not of expected type")
                            expectation.fulfill()
                            return
                        }
                        XCTAssertEqual(sender.identifier, self.participantId)
                        XCTAssertEqual(readReceipt.chatMessageId, self.messageId)
                        XCTAssertNotNil(readReceipt.readOn)

                    case .failure:
                        XCTFail("Unexpected failure happened in list read receipts")
                    }
                }

            case .failure:
                XCTFail("Unexpected failure happened in list read receipts")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("List read receipts timed out: \(error)")
            }
        }
    }

    func test_ListReadReceipts_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "List read receipts")

        chatThreadClient.listReadReceipts(completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in list read receipt")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("List read receipts timed out: \(error)")
            }
        }
    }
}
