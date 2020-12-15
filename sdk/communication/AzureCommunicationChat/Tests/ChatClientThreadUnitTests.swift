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

class ChatClientThreadUnitTests: XCTestCase {

    private var chatClient: ChatClient!
    private var chatClientThread: ChatThreadClient!
    private let timeout: TimeInterval = 3
    
    private let endpoint = "https://www.acsunittest.com"
    private let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMl9pbnQiLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOjliNjY1ZDUzLTgxNjQtNDkyMy1hZDVkLTVlOTgzYjA3ZDJlN18wMDAwMDAwNi1lM2UyLThkZTgtNTU3ZC01YTNhMGQwMDAwNTQiLCJzY3AiOjE3OTIsImNzaSI6IjE2MDc1NDg0NTQiLCJpYXQiOjE2MDc1NDg0NTQsImV4cCI6MTYwNzYzNDg1NCwiYWNzU2NvcGUiOiJjaGF0IiwicmVzb3VyY2VJZCI6IjliNjY1ZDUzLTgxNjQtNDkyMy1hZDVkLTVlOTgzYjA3ZDJlNyJ9.mQ-WzZYiEF_g2Q7VusnOYnvrY4TQ1LWbZfwWiwx1r6S4U2T3IDoaNFgb5RFSH3V3R7VysY5teFtgRlyqh6vTYhU-roSK_i1bWSS1K-gLXOK7sEIS1daNTRgjJ2kpA38MY4o9WD5YeIcZ_NkW7IxyIRwOQI9-h_fFBG7oXNhft1Xq1YfC9LuiHSmTsO67D6ldwHbNRZdjELp5Y2L_O5KOVqx2elPSscXPxXvxbk2E5KDtwX8WDgKDiOX9ZFUooulnAGX8jhblgYSwZW5BYfyuXbAhMXAwot0ay3yUbz3J0smewsxrgYI0FEOtlMfg61Ejxf7vx_OaVB_HFkQYRC_5rw"
    
    private let participantId = "test_participant_id"
    private let participantName = "test_participant_name"
    private let threadId = "test_thread_id"
    private let topic = "test topic"
    private let messageId = "test_message_id"

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
        
        do {
            chatClientThread = try chatClient.createClient(forThread: self.threadId)
        } catch _ {
            XCTFail("Failed to initialize ChatThreadClient")
        }
    }
    
    func test_UpdateThreadTopic_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodPATCH()) { _ in
            return fixture(filePath: path, status: 204, headers: nil)
        }
        
        let expectation = self.expectation(description: "Update thread topic")

        chatClientThread.update(topic: self.topic, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
            case .failure(_):
                XCTFail("Unexpected failure happened in update thread topic")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Update thread topic timed out: \(error)")
            }
        }
    }
    
    func test_UpdateThreadTopic_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPATCH()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "Update thread topic")

        chatClientThread.update(topic: self.topic, completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in update thread topic")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Update thread topic timed out: \(error)")
            }
        }
    }
    
    func test_SendMessage_ReturnSuccess()  {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "SendMessageResponse", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            return fixture(filePath: path, status: 201, headers: nil)
        }
        
        let messageRequest = SendChatMessageRequest(
            priority: ChatMessagePriority.normal,
            content: "Hello world!",
            senderDisplayName: "Leo"
        )
        
        let expectation = self.expectation(description: "Send message")

        chatClientThread.send(message: messageRequest, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
                guard let messageId = response.id else {
                    XCTFail("Failed to extract message id from response")
                    return
                }
                XCTAssertEqual(messageId, self.messageId)
            case .failure(_):
                XCTFail("Unexpected failure happened in send message")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }
    
    func test_SendMessage_ReturnError()  {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let messageRequest = SendChatMessageRequest(
            priority: ChatMessagePriority.normal,
            content: "Hello world!",
            senderDisplayName: "Leo"
        )
        
        let expectation = self.expectation(description: "Send message")

        chatClientThread.send(message: messageRequest, completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in send message")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Send message timed out: \(error)")
            }
        }
    }
    
    func test_GetMessage_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "GetMessageResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 200, headers: nil)
        }
        
        let expectation = self.expectation(description: "Get message")

        chatClientThread.get(message: self.messageId, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
                guard let messageId = response.id else {
                    XCTFail("Failed to extract message id from response")
                    return
                }
                guard let content = response.content else {
                    XCTFail("Failed to extract message content from response")
                    return
                }
                XCTAssertEqual(messageId, self.messageId)
                XCTAssertEqual(content, "Hello world!")
            case .failure(_):
                XCTFail("Unexpected failure happened in get message")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Get message timed out: \(error)")
            }
        }
    }
    
    func test_GetMessage_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "Get message")

        chatClientThread.get(message: self.messageId, completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in get message")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Get message timed out: \(error)")
            }
        }
    }
    
    func test_ListMessages_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "ListMessagesResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 200, headers: nil)
        }
        
        let expectation = self.expectation(description: "List messages")

        chatClientThread.listMessages(completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
                response.nextItem { (result) in
                    switch result {
                    case let .success(message):
                        guard let messageId = message.id else {
                            XCTFail("Failed to extract message id from response")
                            return
                        }
                        guard let content = message.content else {
                            XCTFail("Failed to extract message content from response")
                            return
                        }
                        guard let senderId = message.senderId else {
                            XCTFail("Failed to extract message senderId from response")
                            return
                        }
                        XCTAssertEqual(messageId, self.messageId)
                        XCTAssertEqual(content, "Hello world!")
                        XCTAssertEqual(senderId, self.participantId)
                    case .failure(_):
                        XCTFail("Unexpected failure happened in list messages")
                    }
                    
                }
            case .failure(_):
                XCTFail("Unexpected failure happened in list messages")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("List messages timed out: \(error)")
            }
        }
    }
    
    func test_ListMessages_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "List messages")

        chatClientThread.listMessages(completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in list messages")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("List messages timed out: \(error)")
            }
        }
    }
    
    func test_UpdateMessage_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodPATCH()) { _ in
            return fixture(filePath: path, status: 204, headers: nil)
        }
        
        let expectation = self.expectation(description: "Update message")

        chatClientThread.update(topic: self.topic, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
            case .failure(_):
                XCTFail("Unexpected failure happened in update message")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Update message timed out: \(error)")
            }
        }
    }
    
    func test_UpdateMessage_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPATCH()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "Update message")

        chatClientThread.update(topic: self.topic, completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in update message")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Update message timed out: \(error)")
            }
        }
    }
    
    func test_DeleteMessage_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodDELETE()) { _ in
            return fixture(filePath: path, status: 204, headers: nil)
        }
        
        let expectation = self.expectation(description: "Delete message")

        chatClientThread.delete(message: self.messageId, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
            case .failure(_):
                XCTFail("Unexpected failure happened in delete message")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Delete message timed out: \(error)")
            }
        }
    }
    
    func test_DeleteMessage_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodDELETE()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "Delete message")

        chatClientThread.delete(message: self.messageId, completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in delete message")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Delete message timed out: \(error)")
            }
        }
    }
    
    func test_ListParticipants_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "ListParticipantsResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 200, headers: nil)
        }
        
        let expectation = self.expectation(description: "List participants")

        chatClientThread.listParticipants(completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
                response.nextItem { (result) in
                    switch result {
                    case let .success(participant):
                        guard let participantId = participant.id as? String else {
                            XCTFail("Failed to extract participantId id from response")
                            return
                        }
                        guard let displayName = participant.displayName else {
                            XCTFail("Failed to extract senderDisplayName from response")
                            return
                        }
                        XCTAssertEqual(participantId, self.participantId)
                        XCTAssertEqual(displayName, self.participantName)
                    case .failure(_):
                        XCTFail("Unexpected failure happened in list participants")
                    }
                    
                }
            case .failure(_):
                XCTFail("Unexpected failure happened in list participants")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("List participants timed out: \(error)")
            }
        }
    }
    
    func test_ListParticipants_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "List participants")

        chatClientThread.listParticipants(completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in list participants")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("List participants timed out: \(error)")
            }
        }
    }
    
    func test_AddParticipant_ReturnSuccess() {
        XCTFail()
//        let bundle = Bundle(for: type(of: self))
//        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
//        stub(condition: isMethodPOST()) { _ in
//            return fixture(filePath: path, status: 201, headers: nil)
//        }
//
//        let expectation = self.expectation(description: "Delete message")
//
//        chatClientThread.delete(message: self.messageId, completionHandler: { result, _ in
//            switch result {
//            case let .success(response):
//                XCTAssertNotNil(response)
//            case .failure(_):
//                XCTFail("Unexpected failure happened in delete message")
//            }
//            expectation.fulfill()
//        })
//
//        waitForExpectations(timeout: timeout) { error in
//            if let error = error {
//                XCTFail("Delete message timed out: \(error)")
//            }
//        }
    }
    
    func test_AddParticipant_ReturnError() {
        XCTFail()
    }
    
    func test_RemoveParticipant_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodDELETE()) { _ in
            return fixture(filePath: path, status: 204, headers: nil)
        }
        
        let expectation = self.expectation(description: "Remove Participant")

        chatClientThread.remove(participant: self.participantId, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
            case .failure(_):
                XCTFail("Unexpected failure happened in remove participant")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Remove participant timed out: \(error)")
            }
        }
    }
    
    func test_RemoveParticipant_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodDELETE()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "Remove Participant")

        chatClientThread.remove(participant: self.participantId, completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in remove participant")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Remove participant timed out: \(error)")
            }
        }
    }
    
    func test_SendTypingNotification_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            return fixture(filePath: path, status: 200, headers: nil)
        }
        
        let expectation = self.expectation(description: "Send typing notification")
        
        chatClientThread.sendTypingNotification(completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
            case .failure(_):
                XCTFail("Unexpected failure happened in send typing notification")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Send typing notification timed out: \(error)")
            }
        }
    }
    
    func test_SendTypingNotification_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "Send typing notification")
        
        chatClientThread.sendTypingNotification(completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in send typing notification")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Send typing notification timed out: \(error)")
            }
        }
    }
    
    func test_SendReadReceipt_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "NoContent", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            return fixture(filePath: path, status: 201, headers: nil)
        }
        
        let expectation = self.expectation(description: "Send read receipt")
                
        chatClientThread.sendReadReceipt(forMessage: self.messageId, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
            case .failure(_):
                XCTFail("Unexpected failure happened in send read receipt")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Send read receipt timed out: \(error)")
            }
        }
    }
    
    func test_SendReadReceipt_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodPOST()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "Send read receipt")
                
        chatClientThread.sendReadReceipt(forMessage: self.messageId, completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in send read receipt")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("Send read receipt timed out: \(error)")
            }
        }
    }
    
    func test_ListReadReceipts_ReturnSuccess() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "ListReadReceiptResponse", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 200, headers: nil)
        }
        
        let expectation = self.expectation(description: "List read receipts")

        chatClientThread.listReadReceipts(completionHandler: { result, _ in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
                response.nextItem { (result) in
                    switch result {
                    case let .success(readReceipt):
                        guard let senderId = readReceipt.senderId else {
                            XCTFail("Failed to extract senderId id from response")
                            return
                        }
                        guard let chatMessageId = readReceipt.chatMessageId else {
                            XCTFail("Failed to extract chatMessageId from response")
                            return
                        }
                        guard let readOn = readReceipt.readOn else {
                            XCTFail("Failed to extract readOn from response")
                            return
                        }
                        XCTAssertEqual(senderId, self.participantId)
                        XCTAssertEqual(chatMessageId, self.messageId)
                        XCTAssertNotNil(readOn)
                    case .failure(_):
                        XCTFail("Unexpected failure happened in list read receipts")
                    }
                    
                }
            case .failure(_):
                XCTFail("Unexpected failure happened in list read receipts")
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("List read receipts timed out: \(error)")
            }
        }
    }
    
    func test_ListReadReceipts_ReturnError() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "UnauthorizedError", ofType: "json") ?? ""
        stub(condition: isMethodGET()) { _ in
            return fixture(filePath: path, status: 401, headers: nil)
        }
        
        let expectation = self.expectation(description: "List read receipts")

        chatClientThread.listReadReceipts(completionHandler: { result, _ in
            switch result {
            case .success(_):
                XCTFail("Unexpected failure happened in list read receipt")
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("List read receipts timed out: \(error)")
            }
        }
    }
}
