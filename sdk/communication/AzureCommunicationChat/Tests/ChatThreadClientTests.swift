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
import XCTest

class ChatThreadClientTests: XCTestCase {
    /// An ACS user id.
    private var user1: String = TestConfig.user1
    /// An ACS user id.
    private var user2: String = TestConfig.user1
    /// Id of the thread created in setup.
    private var threadId: String = "testThreadId"
    /// ChatClient initialized in setup.
    private var chatClient: ChatClient!
    /// ChatThreadClient initialized in setup.
    private var chatThreadClient: ChatThreadClient!
    /// Initial thread topic.
    private let topic: String = "General"

    override class func setUp() {
        // Register stubs for playback mode
        if TestConfig.mode == "playback" {
            Recorder.registerStubs()
        }
    }

    override func setUpWithError() throws {
        // Initialize the chatClient
        chatClient = try TestConfig.getChatClient()

        let participant = ChatParticipant(
            id: user1,
            displayName: "User 1"
        )

        let thread = CreateChatThreadRequest(
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
                self.threadId = (createThreadResult.chatThread?.id)!

                if TestConfig.mode == "record" {
                    Recorder.record(name: Recording.createThread, httpResponse: httpResponse)
                }

            case let .failure(error):
                print("Failed to create thread with error: \(error)")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: TestConfig.timeout)

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
                if TestConfig.mode == "record" {
                    Recorder.record(name: Recording.updateTopic, httpResponse: httpResponse)
                }

                // Get thread and verify topic updated
                if TestConfig.mode != "playback" {
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

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Update topic timed out: \(error)")
            }
        }
    }

    func test_SendMessage() {
        let testMessage = SendChatMessageRequest(
            priority: .high,
            content: "Hello World!",
            senderDisplayName: "User 1"
        )

        let expectation = self.expectation(description: "Send message")

        chatThreadClient.send(message: testMessage) { result, httpResponse in
            switch result {
            case let .success(sendMessageResult):
                XCTAssertNotNil(sendMessageResult.id)

                if TestConfig.mode == "record" {
                    Recorder.record(name: Recording.sendMessage, httpResponse: httpResponse)
                }

                // Get message and verify exists

            case let .failure(error):
                XCTFail("Send message failed: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }

    func test_SendTypingNotification() {
        let expectation = self.expectation(description: "Send typing notification")

        chatThreadClient.sendTypingNotification { result, httpResponse in
            switch result {
            case .success:
                if TestConfig.mode == "record" {
                    Recorder.record(name: Recording.sendTypingNotification, httpResponse: httpResponse)
                }

            case let .failure(error):
                XCTFail("Send typing notification failed: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Send typing notification timed out: \(error)")
            }
        }
    }

    func test_SendReadReceipt() {
        let testMessage = SendChatMessageRequest(
            priority: .high,
            content: "Hello World!",
            senderDisplayName: "User 1"
        )

        let expectation = self.expectation(description: "Send read receipt")

        // Send message
        chatThreadClient.send(message: testMessage) { result, _ in
            switch result {
            case let .success(sendMessageResult):
                guard let id = sendMessageResult.id else {
                    XCTFail("Send message failed to get id.")
                    expectation.fulfill()
                    return
                }

                // Send read receipt
                self.chatThreadClient.sendReadReceipt(forMessage: id) { result, httpResponse in
                    switch result {
                    case .success:
                        if TestConfig.mode == "record" {
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

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }

    func test_UpdateChatMessage() {
        let testMessage = SendChatMessageRequest(
            priority: .high,
            content: "Hello World!",
            senderDisplayName: "User 1"
        )

        let expectation = self.expectation(description: "Update message")

        // Send message
        chatThreadClient.send(message: testMessage) { result, _ in
            switch result {
            case let .success(sendMessageResult):
                guard let id = sendMessageResult.id else {
                    XCTFail("Send message failed to get id.")
                    expectation.fulfill()
                    return
                }

                let updatedMessage = UpdateChatMessageRequest(
                    content: "Some new content",
                    priority: .normal
                )

                // Update message
                self.chatThreadClient.update(message: updatedMessage, messageId: id) { result, httpResponse in
                    switch result {
                    case .success:
                        if TestConfig.mode == "record" {
                            Recorder.record(name: Recording.updateMessage, httpResponse: httpResponse)
                        }

                        // Get message and verify updated
                        if TestConfig.mode != "playback" {
                            self.chatThreadClient.get(message: id) { result, _ in
                                switch result {
                                case let .success(message):
                                    XCTAssertEqual(message.content, updatedMessage.content)
                                    XCTAssertEqual(message.priority, updatedMessage.priority)

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

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }

    func test_DeleteMessage() {
        let testMessage = SendChatMessageRequest(
            priority: .high,
            content: "Hello World!",
            senderDisplayName: "User 1"
        )

        let expectation = self.expectation(description: "Delete message")

        // Send message
        chatThreadClient.send(message: testMessage) { result, _ in
            switch result {
            case let .success(sendMessageResult):
                guard let id = sendMessageResult.id else {
                    XCTFail("Send message failed to get id.")
                    expectation.fulfill()
                    return
                }

                // Delete message
                self.chatThreadClient.delete(message: id) { result, httpResponse in
                    switch result {
                    case .success:
                        if TestConfig.mode == "record" {
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

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Delete message timed out: \(error)")
            }
        }
    }

    func test_AddValidParticipant_ReturnsWithoutErrors() {
        let newParticipant = ChatParticipant(
            id: user2,
            displayName: "User 2"
        )

        let expectation = self.expectation(description: "Add participant")

        // Add a participant
        chatThreadClient.add(participants: [newParticipant]) { result, httpResponse in
            switch result {
            case let .success(addParticipantsResult):
                XCTAssertNil(addParticipantsResult.errors)
                if TestConfig.mode == "record" {
                    Recorder.record(name: Recording.addParticipants, httpResponse: httpResponse)
                }

            case let .failure(error):
                XCTFail("Add participants failed: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Add participant timed out: \(error)")
            }
        }
    }

    func test_RemoveParticipant() {
        let removedParticipant = ChatParticipant(
            id: user2,
            displayName: "User 2"
        )

        let expectation = self.expectation(description: "Remove participant")

        // Add a participant
        chatThreadClient.add(participants: [removedParticipant]) { result, _ in
            switch result {
            case .success:
                // Remove the participant
                self.chatThreadClient.remove(participant: removedParticipant.id) { result, httpResponse in
                    switch result {
                    case .success:
                        if TestConfig.mode == "record" {
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

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Remove participant timed out: \(error)")
            }
        }
    }

    func test_ListParticipants_ReturnsParticipants() {
        let removedParticipant = ChatParticipant(
            id: user2,
            displayName: "User 2"
        )

        let expectation = self.expectation(description: "List participants")
        let participantExpectations = [
            self.expectation(description: "Particpant 1"),
            self.expectation(description: "Participant 2")
        ]

        // Add another participant
        chatThreadClient.add(participants: [removedParticipant]) { result, _ in
            switch result {
            case .success:
                // List participants
                self.chatThreadClient.listParticipants { result, httpResponse in
                    switch result {
                    case let .success(participants):
                        // Verify both participants in the list
                        for index in 0 ... 1 {
                            participants.nextItem { result in
                                switch result {
                                case let .success(participant):
                                    XCTAssertNotNil(participant)

                                case let .failure(error):
                                    XCTFail("Failed to retrieve participant: \(error)")
                                }

                                participantExpectations[index].fulfill()
                            }
                        }

                        if TestConfig.mode == "record" {
                            Recorder.record(name: Recording.listParticipants, httpResponse: httpResponse)
                        }

                        expectation.fulfill()

                    case let .failure(error):
                        XCTFail("List participants failed: \(error)")
                        expectation.fulfill()
                        participantExpectations.forEach { expectation in
                            expectation.fulfill()
                        }
                    }
                }

            case let .failure(error):
                XCTFail("Add participant failed: \(error)")
                expectation.fulfill()
                participantExpectations.forEach { expectation in
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("List participants timed out: \(error)")
            }
        }
    }
}
