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

import XCTest
import AzureCommunication
import AzureCommunicationChat

class ChatClientTests: XCTestCase {

    private var chatClient: ChatClient!
    private var validId: String = "1234"
    private var invalidId: String = "5678"

    override func setUp() {
        super.setUp()

        guard let endpoint = ProcessInfo.processInfo.environment["COMMUNICATION_ENDPOINT"] else {
            XCTFail("Failed to retrieve endpoint")
            return
        }

        guard let token = ProcessInfo.processInfo.environment["COMMUNICATION_TOKEN"] else {
            XCTFail("Failed to retrieve token")
            return
        }

        guard let credential = try? CommunicationUserCredential(token: token) else {
            XCTFail("Failed to create credential")
            return
        }

        let options = AzureCommunicationChatClientOptions()

        guard let client = try? ChatClient(endpoint: endpoint, credential: credential, withOptions: options) else {
            XCTFail("Failed to initialize ChatClient")
            return
        }

        self.chatClient = client
        
        guard let id = ProcessInfo.processInfo.environment["COMMUNICATION_USER_ID"]  else {
            XCTFail("Failed to retrieve user ID")
            return
        }
        
        self.validId = id
    }

    func test_CreateThread_ResultContainsChatThread() {
        let participant = ChatParticipant(
            id: self.validId,
            displayName: "Initial Member"
        )
 
        let thread = CreateChatThreadRequest(
            topic: "General",
            participants: [
                participant
            ]
        )

        let expectation = XCTestExpectation(description: "Create Thread")

        self.chatClient.create(thread: thread) { result, _ in
            switch result {
            case let .success(response):
                guard let chatThread = response.chatThread else {
                    XCTFail("Create Thread failed to return chatThread")
                    return
                }

                XCTAssert(chatThread.id != nil)
                XCTAssert(chatThread.topic == thread.topic)
                XCTAssert(chatThread.createdBy == participant.id)
            case let .failure(error):
                XCTFail("Create Thread failed with error: \(error)")
            }

            expectation.fulfill()
        }
    }

    func test_CreateThread_WithInvalidParticipants_ResultContainsErrors() {
        
    }
}

