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
import OHHTTPStubs
import XCTest

class ChatClientTests: XCTestCase {
    /// ChatClient initialized in setup.
    private var chatClient: ChatClient!
    /// An ACS user id.
    private var user: String = TestConfig.user1
    /// Thread topic.
    private let topic: String = "General"

    override class func setUp() {
        if TestConfig.mode == "playback" {
            // Register stubs for playback mode
            Recorder.registerStubs()
        } else {
            // Remove any stubs that have been registered
            HTTPStubs.removeAllStubs()
        }
    }

    override func setUpWithError() throws {
        chatClient = try TestConfig.getChatClient()
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
            displayName: "User",
            shareHistoryTime: Iso8601Date(string: "2016-04-13T00:00:00Z")!
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
            displayName: "User",
            shareHistoryTime: Iso8601Date(string: "2016-04-13T00:00:00Z")!
        )

        let thread = CreateChatThreadRequest(
            topic: topic,
            participants: [
                participant
            ]
        )

        let expectation = self.expectation(description: "Create thread")

        chatClient.create(thread: thread) { result, httpResponse in
            switch result {
            case let .success(response):
                let chatThread = response.chatThread
                XCTAssertNotNil(response.chatThread)
                XCTAssertEqual(chatThread?.topic, thread.topic)

                if TestConfig.mode == "record" {
                    Recorder.record(name: Recording.createThread, httpResponse: httpResponse)
                }

            case let .failure(error):
                XCTFail("Create thread failed with error: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Create thread timed out: \(error)")
            }
        }
    }

    func test_GetThread_ReturnsChatThread() {
        let expectation = self.expectation(description: "Get thread")

        // Create a thread
        createThread(withUser: user, withTopic: topic) { threadId in
            // Get the thread
            self.chatClient.get(thread: threadId) { result, httpResponse in
                switch result {
                case let .success(thread):
                    XCTAssert(thread.topic == self.topic)
                    XCTAssertNotNil(thread.createdBy)

                    if TestConfig.mode == "record" {
                        Recorder.record(name: Recording.getThread, httpResponse: httpResponse)
                    }

                case let .failure(error):
                    XCTFail("Get thread failed with error: \(error)")
                }

                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Get thread timed out: \(error)")
            }
        }
    }

    func test_DeleteThread() {
        let expectation = self.expectation(description: "Delete thread")

        // Create a thread
        createThread(withUser: user, withTopic: topic) { threadId in
            // Delete the thread
            self.chatClient.delete(thread: threadId) { result, httpResponse in
                switch result {
                case .success:
                    if TestConfig.mode == "record" {
                        Recorder.record(name: Recording.deleteThread, httpResponse: httpResponse)
                    }

                    // Get the thread and verify deleted
                    if TestConfig.mode != "playback" {
                        self.chatClient.get(thread: threadId) { result, _ in
                            switch result {
                            case let .success(thread):
                                XCTAssertNotNil(thread.deletedOn)

                            case let .failure(error):
                                XCTFail("Deleted thread failed with error: \(error)")
                            }

                            expectation.fulfill()
                        }
                    } else {
                        expectation.fulfill()
                    }

                case let .failure(error):
                    XCTFail("Delete thread failed: \(error)")
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("Delete thread timed out: \(error)")
            }
        }
    }

    func test_ListThreads_ReturnsThreads() {
        let expectation = self.expectation(description: "List threads")

        // Create a thread
        createThread(withUser: user, withTopic: "Hello World") { _ in
            // List threads
            self.chatClient.listThreads { result, httpResponse in
                switch result {
                case let .success(listThreadsResult):
                    if TestConfig.mode == "record" {
                        Recorder.record(name: Recording.listThreads, httpResponse: httpResponse)
                    }

                    let threads = listThreadsResult.items
                    XCTAssertNotNil(threads)
                    XCTAssertNotNil(threads?.count)
                    XCTAssertNotEqual(threads?.count, 0)

                case let .failure(error):
                    XCTFail("List threads failed: \(error)")
                }

                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: TestConfig.timeout) { error in
            if let error = error {
                XCTFail("List threads timed out: \(error)")
            }
        }
    }
}
