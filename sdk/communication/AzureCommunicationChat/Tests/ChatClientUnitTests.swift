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

class ChatClientUnitTests: XCTestCase {
    private var chatClient: ChatClient!

    private let participantId = "test_participant_id"
    private let threadId = "test_thread_id"
    private let topic = "test topic"

    override func setUpWithError() throws {
        let settings = TestSettings()
        let endpoint = settings.endpoint
        let token = settings.token
        let credential = try CommunicationTokenCredential(token: token)
        let options = AzureCommunicationChatClientOptions()

        chatClient = try ChatClient(endpoint: endpoint, credential: credential, withOptions: options)
    }

    func test_CreateChatThreadClient_ReturnChatThreadClient() {
        do {
            let threadClient = try chatClient.createClient(forThread: threadId)
            XCTAssertEqual(threadClient.threadId, threadId)
        } catch _ {
            XCTFail("Failed in creating chat thread client")
        }
    }

    func test_CreateChatThread_ReturnChatThread() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "CreateThreadResponse", ofType: "json") ?? ""
        stub(condition: isMethodPOST() && isPath("/chat/threads")) { _ in
            fixture(filePath: path, status: 201, headers: nil)
        }

        let participant = ChatParticipant(
            id: CommunicationUserIdentifier("test_participant_id"),
            displayName: "test name",
            shareHistoryTime: Iso8601Date(string: "2016-04-13T00:00:00Z")!
        )

        let request = CreateChatThreadRequest(
            topic: "test topic",
            participants: [
                participant
            ]
        )

        let expectation = self.expectation(description: "Create chat thread")

        chatClient.create(thread: request) { result, _ in
            switch result {
            case let .success(response):
                guard let thread = response.chatThread else {
                    XCTFail("Failed to extract chatThread from response")
                    expectation.fulfill()
                    return
                }
                XCTAssert(thread.id == self.threadId)
                XCTAssert(thread.topic == request.topic)
                guard let createdBy = thread.createdBy as? CommunicationUserIdentifier else {
                    XCTFail("Identifier is not of expected type.")
                    expectation.fulfill()
                    return
                }
                XCTAssert(createdBy.identifier == "test_participant_id")

            case .failure:
                XCTFail("Unexpected failure happened in create chat thread")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Create chat thread timed out: \(error)")
            }
        }
    }

    func test_CreateChatThread_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPOST() && isPath("/chat/threads")) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let participant = ChatParticipant(
            id: CommunicationUserIdentifier("test id"),
            displayName: "test name",
            shareHistoryTime: Iso8601Date(string: "2016-04-13T00:00:00Z")!
        )

        let request = CreateChatThreadRequest(
            topic: "test topic",
            participants: [
                participant
            ]
        )

        let expectation = self.expectation(description: "Create chat thread")

        chatClient.create(thread: request) { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in create chat thread")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Create chat thread timed out: \(error)")
            }
        }
    }

    func test_ListChatThreads_ReturnChatThreads() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "ListThreadsResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 200, headers: nil)
        }

        let expectation = self.expectation(description: "List threads")

        chatClient.listThreads { result, _ in
            switch result {
            case let .success(threads):
                threads.nextItem { result in
                    switch result {
                    case let .success(item):
                        XCTAssert(item.topic == self.topic)
                        XCTAssert(item.id == self.threadId)

                    case .failure:
                        XCTFail("Unexpected failure happened in list chat threads")
                    }

                    expectation.fulfill()
                }

            case .failure:
                XCTFail("Unexpected failure happened in list chat threads")
            }
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("List threads timed out: \(error)")
            }
        }
    }

    func test_ListChatThreads_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "List chat threads")

        chatClient.listThreads { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in list chat threads")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("List chat threads timed out: \(error)")
            }
        }
    }

    func test_DeleteChatThread_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodDELETE()) { _ in
            fixture(filePath: path, status: 204, headers: nil)
        }

        let expectation = self.expectation(description: "Delete chat thread")

        chatClient.delete(thread: threadId, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)

            case .failure:
                XCTFail("Unexpected failure happened in delete chat thread")
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Delete chat thread timed out: \(error)")
            }
        }
    }

    func test_DeleteChatThread_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodDELETE()) { _ in
            fixture(filePath: path, status: 401, headers: nil)
        }

        let expectation = self.expectation(description: "Delete chat thread")

        chatClient.delete(thread: threadId, completionHandler: { result, _ in
            switch result {
            case .success:
                XCTFail("Unexpected failure happened in delete chat thread")

            case let .failure(error):
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        })

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Delete chat thread timed out: \(error)")
            }
        }
    }
}
