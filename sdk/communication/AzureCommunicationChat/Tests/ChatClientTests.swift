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

    /// Tests ChatClient is initialized without error.
    func test_ChatClient_Inits() throws {
        // TODO: handle when env var isn't set
        let endpoint = ProcessInfo.processInfo.environment["COMMUNICATION_CONNECTION_STRING"] ?? ""

        let token = ProcessInfo.processInfo.environment["COMMUNICATION_TOKEN"] ?? ""
        let options = AzureCommunicationChatClientOptions()
        
        guard let credential = try? CommunicationUserCredential(token: token) else {
            XCTFail("Failed to create credential for test.")
            return
        }

        XCTAssertNoThrow(try ChatClient(endpoint: endpoint, credential: credential, withOptions: options))
    }

    func test_CreateThread_ResultContainsChatThread() {

    }

    func test_CreateThread_WithInvalidParticipants_ResultContainsErrors() {
        
    }
}

