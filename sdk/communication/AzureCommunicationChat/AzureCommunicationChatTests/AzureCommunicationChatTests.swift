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
@testable import AzureCommunication
@testable import AzureCore
import XCTest

class ChampionScenarioTests: XCTestCase {
    private let sampleToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"

    func testInitChatClient() {
        do {
            let credential = try CommunicationUserCredential(token: sampleToken)
            let policy = CommunicationUserCredentialPolicy(credential: credential)
            let options = AzureCommunicationChatClientOptions()
            let chatClient = try AzureCommunicationChatClient(endpoint: URL(string: "http://somendpoint.com")!,
                                                        authPolicy: policy,
                                                        withOptions: options)
            
            XCTAssertNotNil(chatClient)
        } catch {
            XCTFail("Failed to create chat client")
        }
    }
        
    func testListParticipantsOfChat() {
        let expectation = XCTestExpectation()
        do {
            let credential = try CommunicationUserCredential(token: sampleToken)
            let policy = CommunicationUserCredentialPolicy(credential: credential)
            let options = AzureCommunicationChatClientOptions()
            let chatClient = try AzureCommunicationChatClient(endpoint: URL(string: "http://somendpoint.com")!,
                                                        authPolicy: policy,
                                                        withOptions: options)
                        
            chatClient.listChatThreadMembers(chatThreadId: "SomeChatThreadId") { (result, httpResponse) in
             
                switch result {
                case let .success(pages):
                    guard let items = pages.items else {
                        XCTFail("Failed to get members back for this thread id")
                        return
                    }
                    
                    if items.count > 0 {
                        pages.forEachItem { (member) -> Bool in
                            guard let name = member.displayName else {
                                print("Chat member has no display name")
                                return false
                            }
                            
                            print("Chat Member display name is: \(name)")
                            return true
                        }
                    }
                    
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failed to get members back for this thread id")
                }
            }
            
        } catch {
            XCTFail("Failed to create chat client")
        }
        
        wait(for: [expectation], timeout: 2)
    }
}
