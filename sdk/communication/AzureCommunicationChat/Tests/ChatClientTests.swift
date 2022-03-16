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
import AzureTest
import XCTest

class ChatClientTests: XCTestCase {
    /// ChatClient initialized in setup.
    private var chatClient: ChatClient!
    /// Test mode.
    private var mode = environmentVariable(forKey: "TEST_MODE", default: "playback")
    /// default test settings
    private let settings = TestSettings()

    override class func setUp() {
        let mode = environmentVariable(forKey: "TEST_MODE", default: "playback")
        if mode == "playback" {
            // Register stubs for playback mode
            Recorder.registerStubs()
        }
    }

    override func setUpWithError() throws {
        let endpoint = settings.endpoint
        let token = settings.token
        let credential = try CommunicationTokenCredential(token: token)
        let options = AzureCommunicationChatClientOptions()

        chatClient = try ChatClient(endpoint: endpoint, credential: credential, withOptions: options)
    }

    func test_CreateThread_WithoutParticipants() {
        let thread = CreateChatThreadRequest(
            topic: "Test topic"
        )

        let expectation = self.expectation(description: "Create thread")

        chatClient.create(thread: thread) { result, httpResponse in
            switch result {
            case let .success(response):
                let chatThread = response.chatThread
                XCTAssertNotNil(response.chatThread)
                XCTAssertEqual(chatThread?.topic, thread.topic)
                XCTAssertNotNil(httpResponse?.httpRequest?.headers["repeatability-request-id"])
                XCTAssertNil(response.invalidParticipants)

                if self.mode == "record" {
                    Recorder.record(name: Recording.createThread, httpResponse: httpResponse)
                }

            case let .failure(error):
                XCTFail("Create thread failed with error: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Create thread timed out: \(error)")
            }
        }
    }

    func test_CreateThread_WithParticipants() {
        let userId = settings.user2
        let thread = CreateChatThreadRequest(
            topic: "Test topic",
            participants: [
                ChatParticipant(
                    id: CommunicationUserIdentifier(userId)
                )
            ]
        )

        chatClient.create(thread: thread) { result, httpResponse in
            switch result {
            case let .success(response):
                let chatThread = response.chatThread
                XCTAssertNotNil(response.chatThread)
                XCTAssertEqual(chatThread?.topic, thread.topic)
                XCTAssertNotNil(httpResponse?.httpRequest?.headers["repeatability-request-id"])
                XCTAssertNil(response.invalidParticipants)

            case let .failure(error):
                XCTFail("Create thread failed with error: \(error)")
            }
        }
    }

    func test_CreateThread_WithIdempotencyToken() {
        let thread = CreateChatThreadRequest(
            topic: "Test topic"
        )

        let options = CreateChatThreadOptions(repeatabilityRequestId: "test-repeatability")

        let expectation = self.expectation(description: "Create thread")

        chatClient.create(thread: thread, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                XCTAssertNotNil(httpResponse?.httpRequest?.headers["repeatability-request-id"])
                XCTAssertEqual(
                    httpResponse?.httpRequest?.headers["repeatability-request-id"],
                    options.repeatabilityRequestId
                )

            case let .failure(error):
                XCTFail("Create thread failed with error: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Create thread timed out: \(error)")
            }
        }
    }

    func test_DeleteThread() {
        let expectation = self.expectation(description: "Delete thread")

        // Create a thread
        let thread = CreateChatThreadRequest(
            topic: "Test topic"
        )

        // Create a thread
        chatClient.create(thread: thread) { result, _ in
            switch result {
            case let .success(createThreadResult):
                // Delete thread
                let threadId = createThreadResult.chatThread?.id
                self.chatClient.delete(thread: threadId!) { result, httpResponse in
                    switch result {
                    case .success:
                        if self.mode == "record" {
                            Recorder.record(name: Recording.deleteThread, httpResponse: httpResponse)
                        }

                    case let .failure(error):
                        XCTFail("Delete thread failed with error: \(error)")
                    }

                    expectation.fulfill()
                }

            case let .failure(error):
                XCTFail("Create thread failed with error: \(error)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Delete thread timed out: \(error)")
            }
        }
    }

    func test_ListThreads_ReturnsChatThreadItems() {
        let expectation = self.expectation(description: "List threads")
        let thread = CreateChatThreadRequest(
            topic: "Test list threads"
        )

        // Create a thread
        chatClient.create(thread: thread) { _, _ in
            // List threads
            self.chatClient.listThreads { result, httpResponse in
                switch result {
                case let .success(listThreadsResult):
                    if self.mode == "record" {
                        Recorder.record(name: Recording.listThreads, httpResponse: httpResponse)
                    }

                    let threads = listThreadsResult.items
                    XCTAssertTrue(threads!.count > 0)

                case let .failure(error):
                    XCTFail("List threads failed: \(error)")
                }

                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("List threads timed out: \(error)")
            }
        }
    }
}
