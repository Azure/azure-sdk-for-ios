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

import AzureCommunication
import AzureCommunicationChat
import AzureCore
import XCTest

// swiftlint:disable type_body_length
// swiftlint:disable file_length

class ChatThreadClientTests: XCTestCase {
    /// An ACS user id.
    private var user1: String = TestUtil.user1
    /// An ACS user id.
    private var user2: String = TestUtil.user2
    /// Id of the thread created in setup.
    private var threadId: String = "testThreadId"
    /// ChatClient initialized in setup.
    private var chatClient: ChatClient!
    /// ChatThreadClient initialized in setup.
    private var chatThreadClient: ChatThreadClient!
    /// Initial thread topic.
    private let topic: String = "General"

    override class func setUp() {
        if TestUtil.mode == "playback" {
            // Register stubs for playback mode
            Recorder.registerStubs()
        }
    }

    override func setUpWithError() throws {
        // Initialize the chatClient
        chatClient = try TestUtil.getChatClient()

        let participant = Participant(
            id: CommunicationUserIdentifier(user1),
            displayName: "User 1",
            shareHistoryTime: Iso8601Date(string: "2016-04-13T00:00:00Z")!
        )

        let thread = CreateThreadRequest(
            topic: topic,
            participants: [
                participant
            ]
        )

        let expectation = self.expectation(description: "Create thread")

        // Create a thread for the test
        chatClient.create(thread: thread) { result, httpResponse in
            switch result {
            case let .success(createThreadResult):
                // Initialize threadId
                self.threadId = (createThreadResult.thread?.id)!

                if TestUtil.mode == "record" {
                    Recorder.record(name: Recording.createThread, httpResponse: httpResponse)
                }

            case let .failure(error):
                print("Failed to create thread with error: \(error)")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TestUtil.timeout)

        // Initialize the ChatThreadClient
        chatThreadClient = try chatClient.createClient(forThread: threadId)
    }

    func test_UpdateTopic() {
        let newTopic = "New topic"
        let expectation = self.expectation(description: "Update topic")

        // Update topic
        chatThreadClient.update(topic: newTopic) { result, httpResponse in
            switch result {
            case .success:
                if TestUtil.mode == "record" {
                    Recorder.record(name: Recording.updateTopic, httpResponse: httpResponse)
                }

                // Get thread and verify topic updated
                if TestUtil.mode != "playback" {
                    self.chatClient.get(thread: self.threadId) { result, _ in
                        switch result {
                        case let .success(chatThread):
                            XCTAssertEqual(chatThread.topic, newTopic)

                        case let .failure(error):
                            XCTFail("Failed to update topic: \(error)")
                        }

                        expectation.fulfill()
                    }
                } else {
                    expectation.fulfill()
                }

            case let .failure(error):
                XCTFail("Failed to update topic: \(error)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("Update topic timed out: \(error)")
            }
        }
    }

    func test_SendMessage_ReturnsMessageId() {
        let testMessage = SendChatMessageRequest(
            content: "Hello World!",
            senderDisplayName: "User 1",
            type: .text
        )

        let expectation = self.expectation(description: "Send message")

        chatThreadClient.send(message: testMessage) { result, httpResponse in
            switch result {
            case let .success(sendMessageResult):
                if TestUtil.mode == "record" {
                    Recorder.record(name: Recording.sendMessage, httpResponse: httpResponse)
                }
                XCTAssertNotNil(sendMessageResult.id)

            case let .failure(error):
                XCTFail("Send message failed: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }

    func test_SendMessage_SendsHTML() {
        let testMessage = SendChatMessageRequest(
            content: "<div>Hello</div>",
            senderDisplayName: "User 1",
            type: .html
        )

        let expectation = self.expectation(description: "Send message")

        chatThreadClient.send(message: testMessage) { result, _ in
            switch result {
            case let .success(sendMessageResult):
                XCTAssertNotNil(sendMessageResult.id)

            case let .failure(error):
                XCTFail("Send message failed to send HTML: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }

    func test_ListMessages_ReturnsMessages() {
        let testMessage = SendChatMessageRequest(
            content: "Hello World!",
            senderDisplayName: "User 1",
            type: .text
        )

        let expectation = self.expectation(description: "List messages")

        // Send a couple messages
        chatThreadClient.send(message: testMessage) { _, _ in
            self.chatThreadClient.send(message: testMessage) { _, _ in
                // List messages
                self.chatThreadClient.listMessages { result, httpResponse in
                    switch result {
                    case let .success(listMessagesResult):
                        if TestUtil.mode == "record" {
                            Recorder.record(name: Recording.listMessages, httpResponse: httpResponse)
                        }

                        let messages = listMessagesResult.items
                        messages?.forEach { message in
                            if message.type == ChatMessageType.text {
                                XCTAssertEqual(message.content?.message, testMessage.content)
                                XCTAssertEqual(message.senderDisplayName, testMessage.senderDisplayName)
                            }
                        }

                        XCTAssertNotNil(messages)

                    case let .failure(error):
                        XCTFail("List messages failed: \(error)")
                    }

                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("List messages timed out: \(error)")
            }
        }
    }

    func test_SendTypingNotification() {
        let expectation = self.expectation(description: "Send typing notification")

        chatThreadClient.sendTypingNotification { result, httpResponse in
            switch result {
            case .success:
                if TestUtil.mode == "record" {
                    Recorder.record(name: Recording.sendTypingNotification, httpResponse: httpResponse)
                }

            case let .failure(error):
                XCTFail("Send typing notification failed: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("Send typing notification timed out: \(error)")
            }
        }
    }

    func test_SendReadReceipt() {
        let testMessage = SendChatMessageRequest(
            content: "Hello World!",
            senderDisplayName: "User 1",
            type: .text
        )

        let expectation = self.expectation(description: "Send read receipt")

        // Send message
        chatThreadClient.send(message: testMessage) { result, _ in
            switch result {
            case let .success(sendMessageResult):
                // Send read receipt
                self.chatThreadClient.sendReadReceipt(forMessage: sendMessageResult.id) { result, httpResponse in
                    switch result {
                    case .success:
                        if TestUtil.mode == "record" {
                            Recorder.record(name: Recording.sendReadReceipt, httpResponse: httpResponse)
                        }

                    case let .failure(error):
                        XCTFail("Send read receipt failed: \(error)")
                    }

                    expectation.fulfill()
                }

            case let .failure(error):
                XCTFail("Send message failed: \(error)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }

    func test_ListReadReceipts_ReturnsReadReceipts() {
        let testMessage = SendChatMessageRequest(
            content: "Hello World!",
            senderDisplayName: "User 1",
            type: .text
        )

        let expectation = self.expectation(description: "Send read receipt")

        // Send message
        chatThreadClient.send(message: testMessage) { result, _ in
            switch result {
            case let .success(sendMessageResult):
                // Send read receipt
                self.chatThreadClient.sendReadReceipt(forMessage: sendMessageResult.id) { result, _ in
                    switch result {
                    case .success:
                        // List read receipts
                        self.chatThreadClient.listReadReceipts { result, httpResponse in
                            switch result {
                            case let .success(readReceipts):
                                if TestUtil.mode == "record" {
                                    Recorder.record(name: Recording.listReadReceipts, httpResponse: httpResponse)
                                }

                                readReceipts.items?.forEach { readReceipt in
                                    XCTAssertNotNil(readReceipt.sender)
                                    XCTAssertEqual(readReceipt.chatMessageId, sendMessageResult.id)
                                }

                                XCTAssertNotNil(readReceipts.items)
                            case let .failure(error):
                                XCTFail("List read receipts failed: \(error)")
                            }

                            expectation.fulfill()
                        }

                    case let .failure(error):
                        XCTFail("Send read receipt failed: \(error)")
                        expectation.fulfill()
                    }
                }

            case let .failure(error):
                XCTFail("Send message failed: \(error)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }

    func test_UpdateChatMessage() {
        let testMessage = SendChatMessageRequest(
            content: "Hello World!",
            senderDisplayName: "User 1",
            type: .text
        )

        let expectation = self.expectation(description: "Update message")

        // Send message
        chatThreadClient.send(message: testMessage) { result, _ in
            switch result {
            case let .success(sendMessageResult):
                let updatedMessage = UpdateChatMessageRequest(
                    content: "Some new content"
                )

                // Update message
                self.chatThreadClient
                    .update(message: updatedMessage, messageId: sendMessageResult.id) { result, httpResponse in
                        switch result {
                        case .success:
                            if TestUtil.mode == "record" {
                                Recorder.record(name: Recording.updateMessage, httpResponse: httpResponse)
                            }

                            // Get message and verify updated
                            if TestUtil.mode != "playback" {
                                self.chatThreadClient.get(message: sendMessageResult.id) { result, _ in
                                    switch result {
                                    case let .success(message):
                                        XCTAssertEqual(message.content?.message, updatedMessage.content)

                                    case let .failure(error):
                                        XCTFail("Get message failed: \(error)")
                                    }

                                    expectation.fulfill()
                                }
                            } else {
                                expectation.fulfill()
                            }

                        case let .failure(error):
                            XCTFail("Update message failed: \(error)")
                            expectation.fulfill()
                        }
                    }

            case let .failure(error):
                XCTFail("Send message failed: \(error)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }

    func test_DeleteMessage() {
        let testMessage = SendChatMessageRequest(
            content: "Hello World!",
            senderDisplayName: "User 1",
            type: .text
        )

        let expectation = self.expectation(description: "Delete message")

        // Send message
        chatThreadClient.send(message: testMessage) { result, _ in
            switch result {
            case let .success(sendMessageResult):
                // Delete message
                self.chatThreadClient.delete(message: sendMessageResult.id) { result, httpResponse in
                    switch result {
                    case .success:
                        if TestUtil.mode == "record" {
                            Recorder.record(name: Recording.deleteMessage, httpResponse: httpResponse)
                        }

                    case let .failure(error):
                        XCTFail("Delete message failed: \(error)")
                    }

                    expectation.fulfill()
                }

            case let .failure(error):
                XCTFail("Send message failed: \(error)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("Delete message timed out: \(error)")
            }
        }
    }

    func test_AddValidParticipant_ReturnsWithoutErrors() {
        let newParticipant = Participant(
            id: CommunicationUserIdentifier(user2),
            displayName: "User 2",
            shareHistoryTime: Iso8601Date(string: "2016-04-13T00:00:00Z")!
        )

        let expectation = self.expectation(description: "Add participant")

        // Add a participant
        chatThreadClient.add(participants: [newParticipant]) { result, httpResponse in
            switch result {
            case let .success(addParticipantsResult):
                XCTAssertNil(addParticipantsResult.errors)
                if TestUtil.mode == "record" {
                    Recorder.record(name: Recording.addParticipants, httpResponse: httpResponse)
                }

            case let .failure(error):
                XCTFail("Add participants failed: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("Add participant timed out: \(error)")
            }
        }
    }

    func test_RemoveParticipant() {
        let removedParticipant = Participant(
            id: CommunicationUserIdentifier(user2),
            displayName: "User 2",
            shareHistoryTime: Iso8601Date(string: "2016-04-13T00:00:00Z")!
        )

        let expectation = self.expectation(description: "Remove participant")

        // Add a participant
        chatThreadClient.add(participants: [removedParticipant]) { result, _ in
            switch result {
            case .success:
                // Remove the participant
                self.chatThreadClient
                    .remove(participant: CommunicationUserIdentifier(self.user2)) { result, httpResponse in
                        switch result {
                        case .success:
                            if TestUtil.mode == "record" {
                                Recorder.record(name: Recording.removeParticipant, httpResponse: httpResponse)
                            }

                        case let .failure(error):
                            XCTFail("Remove participant failed: \(error)")
                        }

                        expectation.fulfill()
                    }

            case let .failure(error):
                XCTFail("Remove participants failed: \(error)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("Remove participant timed out: \(error)")
            }
        }
    }

    func test_ListParticipants_ReturnsParticipants() {
        let anotherParticipant = Participant(
            id: CommunicationUserIdentifier(user2),
            displayName: "User 2",
            shareHistoryTime: Iso8601Date(string: "2016-04-13T00:00:00Z")!
        )

        let expectation = self.expectation(description: "List participants")

        // Add a participant
        chatThreadClient.add(participants: [anotherParticipant]) { result, httpResponse in
            switch result {
            case .success:
                // List participants
                self.chatThreadClient.listParticipants { result, httpResponse in
                    if TestUtil.mode == "record" {
                        Recorder.record(name: Recording.listParticipants, httpResponse: httpResponse)
                    }

                    switch result {
                    case let .success(participantsResult):
                        let participants = participantsResult.pageItems
                        participants?.forEach { participant in
                            XCTAssertNotNil(participant.id)
                            XCTAssertNotNil(participant.displayName)
                        }

                        XCTAssertEqual(participants?.count, 2)

                    case let .failure(error):
                        XCTFail("List participants failed: \(error)")
                    }

                    expectation.fulfill()
                }

            case let .failure(error):
                XCTFail("Add participants failed: \(error)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: TestUtil.timeout) { error in
            if let error = error {
                XCTFail("List participants timed out: \(error)")
            }
        }
    }
}
