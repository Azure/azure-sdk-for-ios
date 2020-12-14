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

class ChatClientTests: XCTestCase {
    /// ChatClient initialized in setup
    private var chatClient: ChatClient!
    /// A valid ACS user id initialized in setup
    private var user: String!
    /// Thread topic
    private let topic: String = "General"

    override func setUpWithError() throws {
        let (id, _) = try TestSetup.getUsers()
        user = id

        chatClient = try TestSetup.getChatClient()
    }

    /// Helper to create a thread for tests that act on an existing thread.
    /// - Parameters:
    ///   - id: The user id.
    ///   - topic: The thread topic.
    ///   - completionHandler: Completion handler that receives the thread id of the created thread.
    func createThread(
        withUser id: String,
        withTopic topic: String,
        completionHandler: @escaping (String) -> Void
    ) {
        let participant = ChatParticipant(
            id: id,
            displayName: "User"
        )

        let thread = CreateChatThreadRequest(
            topic: topic,
            participants: [
                participant
            ]
        )

        chatClient.create(thread: thread) { result, _ in
            switch result {
            case let .success(chatThreadResult):
                guard let threadId = chatThreadResult.chatThread?.id else {
                    XCTFail("Failed to get thread id")
                    return
                }

                completionHandler(threadId)
            case let .failure(error):
                XCTFail("Error creating thread: \(error)")
            }
        }
    }

    func test_CreateThread_ResultContainsChatThread() {
        let participant = ChatParticipant(
            id: user,
            displayName: "User"
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
            case let .success(response):
                guard let chatThread = response.chatThread else {
                    XCTFail("Create thread failed to return chatThread")
                    return
                }

                XCTAssert(chatThread.id != nil)
                XCTAssert(chatThread.topic == thread.topic)
                XCTAssert(chatThread.createdBy == participant.id)

            case let .failure(error):
                XCTFail("Create thread failed with error: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestSetup.timeout) { error in
            if let error = error {
                XCTFail("Create thread timed out: \(error)")
            }
        }
    }

    func test_GetThread_ReturnsChatThread() {
        let expectation = self.expectation(description: "Get thread")

        createThread(withUser: user, withTopic: topic) { threadId in
            self.chatClient.get(thread: threadId) { result, _ in
                switch result {
                case let .success(thread):
                    XCTAssert(thread.topic == self.topic)
                    XCTAssert(thread.createdBy == self.user)

                case let .failure(error):
                    XCTFail("Get thread failed with error: \(error)")
                }

                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: TestSetup.timeout) { error in
            if let error = error {
                XCTFail("Get thread timed out: \(error)")
            }
        }
    }

    func test_ListThreads_ReturnsChatThreadInfos() {
        let expectation = self.expectation(description: "List threads")

        createThread(withUser: user, withTopic: topic) { _ in
            self.chatClient.listThreads { result, _ in
                switch result {
                case let .success(threads):
                    threads.nextItem { result in
                        switch result {
                        case let .success(item):
                            XCTAssert(item.topic == self.topic)

                        case let .failure(error):
                            XCTFail("List threads failed to return threadInfo: \(error)")
                        }

                        expectation.fulfill()
                    }

                case let .failure(error):
                    XCTFail("List threads failed with error: \(error)")
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: TestSetup.timeout) { error in
            if let error = error {
                XCTFail("List thread timed out: \(error)")
            }
        }
    }

    func test_DeleteThread() {
        let expectation = self.expectation(description: "Delete thread")

        createThread(withUser: user, withTopic: topic) { threadId in
            self.chatClient.delete(thread: threadId) { result, _ in
                self.chatClient.get(thread: threadId) { result, _ in
                    switch result {
                    case let .success(thread):
                        XCTAssertNotNil(thread.deletedOn)

                    case let .failure(error):
                        XCTFail("Deleted thread failed with error: \(error)")
                    }

                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: TestSetup.timeout) { error in
            if let error = error {
                XCTFail("Delete thread timed out: \(error)")
            }
        }
    }
}
