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
import OHHTTPStubsSwift
import XCTest

class ChatClientUnitTests: XCTestCase {

    private var chatClient: ChatClient!
    private let timeout: TimeInterval = 3
    
    private let endpoint = "https://www.acsunittest.com"
    private let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMl9pbnQiLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOjliNjY1ZDUzLTgxNjQtNDkyMy1hZDVkLTVlOTgzYjA3ZDJlN18wMDAwMDAwNi1lM2UyLThkZTgtNTU3ZC01YTNhMGQwMDAwNTQiLCJzY3AiOjE3OTIsImNzaSI6IjE2MDc1NDg0NTQiLCJpYXQiOjE2MDc1NDg0NTQsImV4cCI6MTYwNzYzNDg1NCwiYWNzU2NvcGUiOiJjaGF0IiwicmVzb3VyY2VJZCI6IjliNjY1ZDUzLTgxNjQtNDkyMy1hZDVkLTVlOTgzYjA3ZDJlNyJ9.mQ-WzZYiEF_g2Q7VusnOYnvrY4TQ1LWbZfwWiwx1r6S4U2T3IDoaNFgb5RFSH3V3R7VysY5teFtgRlyqh6vTYhU-roSK_i1bWSS1K-gLXOK7sEIS1daNTRgjJ2kpA38MY4o9WD5YeIcZ_NkW7IxyIRwOQI9-h_fFBG7oXNhft1Xq1YfC9LuiHSmTsO67D6ldwHbNRZdjELp5Y2L_O5KOVqx2elPSscXPxXvxbk2E5KDtwX8WDgKDiOX9ZFUooulnAGX8jhblgYSwZW5BYfyuXbAhMXAwot0ay3yUbz3J0smewsxrgYI0FEOtlMfg61Ejxf7vx_OaVB_HFkQYRC_5rw"
    
    private let participantId = "test_participant_id"
    private let threadId = "test_thread_id"
    private let topic = "test topic"

    override func setUp() {
        super.setUp()
        guard let credential = try? CommunicationUserCredential(token: self.token) else {
            self.continueAfterFailure = false
            XCTFail("Failed to create credential")
            return
        }

        let options = AzureCommunicationChatClientOptions()

        guard let client = try? ChatClient(endpoint: self.endpoint, credential: credential, withOptions: options) else {
            XCTFail("Failed to initialize ChatClient")
            return
        }

        chatClient = client
    }

    func test_CreateChatThreadClient_ReturnChatThreadClient() {
        do {
            let threadClient = try chatClient.createClient(forThread: self.threadId)
            XCTAssertEqual(threadClient.threadId, self.threadId)
        } catch _ {
            XCTFail("Failed in creating chat thread client")
        }
    }
    
    func test_CreateChatThread_ReturnChatThread() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "CreateThreadResponse", ofType: "json") ?? ""
        stub(condition: isMethodPOST() && isPath("/chat/threads")) { _ in
            return fixture(filePath: path, status: 201, headers: nil)
        }
        
        let participant = ChatParticipant(
            id: "test participant id",
            displayName: "test name"
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
                    return
                }
                XCTAssert(thread.id == participant.id)
                XCTAssert(thread.topic == request.topic)
                XCTAssert(thread.createdBy == participant.id)
            case .failure(_):
                XCTFail("Unexpected failure happened in create chat thread")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Create chat thread timed out: \(error)")
            }
        }
    }
    
    func test_CreateChatThread_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPOST() && isPath("/chat/threads")) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let participant = ChatParticipant(
            id: "test id",
            displayName: "test name"
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
            case .success(_):
                XCTFail("Unexpected failure happened in create chat thread")

            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Create chat thread timed out: \(error)")
            }
        }
    }
    
    func test_GetChatThread_ReturnChatThread() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "GetThreadResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 200, headers: nil)
        }
        
        let expectation = self.expectation(description: "Create thread")
        chatClient.get(thread: self.threadId) { result, _ in
            switch result {
            case let .success(chatThread):
                guard let threadId = chatThread.id else {
                    XCTFail("Failed to extract thread id from response")
                    return
                }
                guard let topic = chatThread.topic else {
                    XCTFail("Failed to extract thread topic from response")
                    return
                }
                guard let createdBy = chatThread.createdBy else {
                    XCTFail("Failed to extract createdBy from response")
                    return
                }
                XCTAssertEqual(threadId, self.threadId)
                XCTAssertEqual(topic, self.topic)
                XCTAssertEqual(createdBy, self.participantId)
            case .failure(_):
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Get thread timed out: \(error)")
            }
        }
    }
    
    func test_GetChatThread_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "Get thread")
        chatClient.get(thread: self.threadId) { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in get thread")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Get thread timed out: \(error)")
            }
        }
    }
    
    func test_ListChatThreads_ReturnChatThreads() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "ListThreadsResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 200, headers: nil)
        }
                
        let expectation = self.expectation(description: "Create thread")
        chatClient.listThreads { (result, _) in
            switch result {
            case let .success(threads):
                threads.nextItem { result in
                    switch result {
                    case let .success(item):
                        guard let threadId = item.id else {
                            XCTFail("Failed to extract thread id from response")
                            return
                        }
                        guard let topic = item.topic else {
                            XCTFail("Failed to extract thread topic from response")
                            return
                        }
                        XCTAssert(topic == self.topic)
                        XCTAssert(threadId == self.threadId)
                    case .failure(_):
                        XCTFail("Unexpected failure happened in list chat threads")
                    }
                    expectation.fulfill()
                }
            case .failure(_):
                XCTFail("Unexpected failure happened in list chat threads")
            }
        }
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("List threads timed out: \(error)")
            }
        }
    }
    
    func test_ListChatThreads_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
                
        let expectation = self.expectation(description: "List chat threads")
        
        chatClient.listThreads { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in list chat threads")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("List chat threads timed out: \(error)")
            }
        }
    }
    
    func test_DeleteChatThread_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodDELETE()) { _ in
            return fixture(filePath: path, status: 204, headers: nil)
        }
                
        let expectation = self.expectation(description: "Delete chat thread")

        chatClient.delete(thread: self.threadId, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
            case .failure(_):
                XCTFail("Unexpected failure happened in delete chat thread")
            }
            expectation.fulfill()
        })
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Delete chat thread timed out: \(error)")
            }
        }
    }
    
    func test_DeleteChatThread_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
                
        let expectation = self.expectation(description: "List chat threads")
        
        chatClient.delete(thread: self.threadId, completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in delete chat thread")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Delete chat thread timed out: \(error)")
            }
        }
    }
}
