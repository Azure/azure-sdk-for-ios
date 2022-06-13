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
import AzureTest
import DVR
import XCTest

class ChatClientDVRTests: RecordableXCTestCase<TestSettings> {
    /// ChatClient initialized in setup.
    private var chatClient: ChatClient!

    private var urlFilter: RequestURLFilter {
        let defaults = TestSettings()
        let textFilter = RequestURLFilter()
        textFilter.register(replacement: defaults.endpoint, for: settings.endpoint)
        return textFilter
    }

    override func setUpTestWithError() throws {
        add(filter: urlFilter)
        let endpoint = settings.endpoint
        let token = settings.token
        let credential = try CommunicationTokenCredential(token: token)
        let options = AzureCommunicationChatClientOptions(transportOptions: transportOptions)

        chatClient = try ChatClient(endpoint: endpoint, credential: credential, withOptions: options)
        chatClient.registrationId = "0E0F0BE0-0000-00C0-B000-A00A00E00BD0"
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

    func test_ListThreads_ReturnsChatThreadItems() {
        let expectation = self.expectation(description: "List threads")
        let thread = CreateChatThreadRequest(
            topic: "Test list threads"
        )

        // Create a thread
        chatClient.create(thread: thread) { _, _ in
            // List threads
            self.chatClient.listThreads { result, _ in
                switch result {
                case let .success(listThreadsResult):
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

    func test_StartPushNotifications_ReturnsSuccess() {
        let expectation = self.expectation(description: "Start push notifications")

        chatClient
            .startPushNotifications(deviceToken: "mockDeviceToken") { result in
                switch result {
                case let .success(response):
                    XCTAssertEqual(response?.statusCode, 202)
                    expectation.fulfill()
                case .failure:
                    XCTFail("Start push notifications failed.")
                }
            }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Start push notifications timed out: \(error)")
            }
        }
    }

    func test_StopPushNotifications_ReturnsSuccess() {
        let expectation = self.expectation(description: "Stop push notifications")

        // Start notifications first
        chatClient
            .startPushNotifications(deviceToken: "mockDeviceToken") { result in
                switch result {
                case .success:
                    // Stop notifications
                    self.chatClient.stopPushNotifications { result in
                        switch result {
                        case let .success(response):
                            XCTAssertEqual(response?.statusCode, 202)
                            expectation.fulfill()
                        case .failure:
                            XCTFail("Stop push notifications failed.")
                        }
                    }
                case .failure:
                    XCTFail("Start push notifications failed.")
                }
            }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Stop push notifications timed out: \(error)")
            }
        }
    }
}
