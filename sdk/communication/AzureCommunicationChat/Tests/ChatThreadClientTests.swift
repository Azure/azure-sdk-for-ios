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
    
    /// A valid ACS user id initialized in setup.
    private var user1: String!
    /// A valid ACS user id initialized in setup.
    private var user2: String!
    /// Id of the thread created in setup.
    private var threadId: String!
    /// ChatClient initialized in setup.
    private var chatClient: ChatClient!
    /// ChatThreadClient initialized in setup.
    private var chatThreadClient: ChatThreadClient!
    /// Initial thread topic.
    private let topic: String = "General"

    override func setUpWithError() throws {
        chatClient = try TestUtil.getChatClient()
        (user1, user2) = try TestUtil.getUsers()

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

        chatClient.create(thread: thread) { result, _ in
            switch result {
            case let .success(createThreadResult):
                self.threadId = createThreadResult.chatThread?.id

            case let .failure(error):
                print("Failed to create thread with error: \(error)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TestUtil.timeout)

        if threadId == nil {
            throw TestUtil.TestError.missingData("Thread id not found.")
        }

        chatThreadClient = try chatClient.createClient(forThread: threadId)
    }

    func test_UpdateTopic() {
        let newTopic = "New topic"
        let expectation = self.expectation(description: "Update topic")

        // Update topic
        chatThreadClient.update(topic: newTopic) { result, _ in
            switch result {
            case .success:
                // Get thread and verify topic updated
                self.chatClient.get(thread: self.threadId) { result, _ in
                    switch result {
                    case let .success(chatThread):
                        // TODO: not updated
                        XCTAssert(chatThread.topic == newTopic)

                    case let .failure(error):
                        XCTFail("Failed to update topic: \(error)")
                    }
                    
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
    
    func test_SendMessage() {
        let testMessage = SendChatMessageRequest(
            priority: .high,
            content: "Hello World!",
            senderDisplayName: "User 1"
        )
        
        let expectation = self.expectation(description: "Send message")

        // Send message
        chatThreadClient.send(message: testMessage) { result, _ in
            switch result {
            case let .success(sendMessageResult):
                guard let id = sendMessageResult.id else {
                    XCTFail("Send message failed to get id.")
                    expectation.fulfill()
                    return
                }

                // Get and verify sent message
                self.chatThreadClient.get(message: id) { result, _ in
                    switch result {
                    case let .success(message):
                        XCTAssert(message.content == testMessage.content)
                        XCTAssert(message.senderDisplayName == testMessage.senderDisplayName)

                    case let .failure(error):
                        XCTFail("Get message failed: \(error)")
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

    func test_SendTypingNotification() {
        let expectation = self.expectation(description: "Send typing notification")

        chatThreadClient.sendTypingNotification() { result, _ in
            switch result {
            case .success:
                break
            
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
                self.chatThreadClient.sendReadReceipt(forMessage: id) { result, _ in
                    switch result {
                    case .success:
                        break

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
                self.chatThreadClient.update(message: updatedMessage, messageId: id) { result, _ in
                    switch result {
                    case .success:
                        // Get message and verify updated
                        self.chatThreadClient.get(message: id) { result, _ in
                            switch result {
                            case let .success(message):
                                // TODO: not updated
                                XCTAssert(message.content == updatedMessage.content)
                                XCTAssert(message.priority == updatedMessage.priority)
                            
                            case let .failure(error):
                                XCTFail("Get message failed: \(error)")
                            }

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
                self.chatThreadClient.delete(message: id) { result, _ in
                    switch result {
                    case .success:
                        // Get message and verify deleted
                        self.chatThreadClient.get(message: id) { result, _ in
                            switch result {
                            case let .success(message):
                                XCTAssertNotNil(message.deletedOn)
                            
                            case let .failure(error):
                                XCTFail("Get message failed: \(error)")
                            }
                            
                            expectation.fulfill()
                        }

                    case let .failure(error):
                        XCTFail("Delete message failed: \(error)")
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
                XCTFail("Delete message timed out: \(error)")
            }
        }
    }
    
    // TODO: failing on add participant
    func test_AddValidParticipant_ReturnsWithoutErrors() {
        let newParticipant = ChatParticipant(
            id: user2,
            displayName: "User 2"
        )
        
        let expectation = self.expectation(description: "Add participant")

        // Add a participant
        chatThreadClient.add(participants: [newParticipant]) { result, _ in
            switch result {
            case let .success(addParticipantsResult):
                XCTAssertNil(addParticipantsResult.errors)
                
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
        /// add participant, delete participant, get participants
    }
    
    // TODO: failing on add participant
    func test_ListParticipants_ReturnsParticipants() {
        let newParticipant = ChatParticipant(
            id: user2,
            displayName: "User 2"
        )
        
        let expectation = self.expectation(description: "Add participant")

        // Add a participant
        chatThreadClient.add(participants: [newParticipant]) { result, _ in
            switch result {
            case let .success(addParticipantsResult):
                XCTAssertNil(addParticipantsResult.errors)
                
                // List participants
                self.chatThreadClient.listParticipants() { result, _ in
                    switch result {
                    case let .success(participants):
//                        var iterator = participants.syncIterator
//                        while let participant = iterator.next() {
//                            XCTAssertNotNil(participant.id)
//                        }
//
                        let count = participants.items?.count
                    
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
                XCTFail("Add participant timed out: \(error)")
            }
        }
    }
    
    func test_ListMessages_ReturnsMessages() {
        /// send 5 messages, list 5 messages
    }
    
    func test_ListReadReceipts_ReturnsReadReceipts() {
        /// send 5 messages, send 5 read receipts, list all read receipts
    }
}
