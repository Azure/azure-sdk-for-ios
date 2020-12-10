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
        
        chatClient.create(thread: thread) { result, _ in
            switch result {
            case let .success(createThreadResult):
                self.threadId = createThreadResult.chatThread?.id
            case let .failure(error):
                print("Failed to create thread with error: \(error)")
            }
        }

        chatThreadClient = try chatClient.createClient(forThread: threadId)
    }

    func test_UpdateTopic() {
        /// update topic, get thread check topic updated
    }
    
    func test_Send_ReadReceipt() {
        /// send message, send read receipt, list read receipts
    }
    
    func test_ListReadReceipts_ReturnsReadReceipts() {
        /// send 5 messages, send 5 read receipts, list all read receipts
    }

    func test_SendTypingNotification() {
        /// send typing notification
    }
    
    func test_SendChatMessage() {
        /// send message, get message
    }
    
    func test_UpdateChatMessage() {
        /// send message, update message, get message
    }
    
    func test_DeleteMessage() {
        /// send message, delete message, get message
    }
    
    func test_ListMessages_ReturnsMessages() {
        /// send 5 messages, list 5 messages
    }
    
    func test_AddValidParticipant_ReturnsWithoutErrors() {
        /// add another participant, get participants
    }
    
    func test_RemoveParticipant() {
        /// add participant, delete participant, get participants
    }
    
    func test_ListParticipants_ReturnsParticipants() {
        /// add 5 participants, list participants
    }
}
