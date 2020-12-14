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
import Foundation

class TestSetup {
    public static let timeout: TimeInterval = 100.0

    public enum TestError: Error {
        case missingData(String)
    }

    /// Creates and returns a ChatClient
    public static func getChatClient() throws -> ChatClient {
        guard let endpoint = ProcessInfo.processInfo.environment["AZURE_COMMUNICATION_ENDPOINT"] else {
            throw TestError.missingData("No endpoint found.")
        }

        guard let token = ProcessInfo.processInfo.environment["AZURE_COMMUNICATION_TOKEN"] else {
            throw TestError.missingData("No token found.")
        }

        let credential = try CommunicationUserCredential(token: token)
        let options = AzureCommunicationChatClientOptions()

        return try ChatClient(endpoint: endpoint, credential: credential, withOptions: options)
    }

    /// Returns two valid ACS user id's.
    public static func getUsers() throws -> (String, String) {
        guard let userId1 = ProcessInfo.processInfo.environment["AZURE_COMMUNICATION_USER_ID_1"] else {
            throw TestError.missingData("No user id found.")
        }

        guard let userId2 = ProcessInfo.processInfo.environment["AZURE_COMMUNICATION_USER_ID_2"] else {
            throw TestError.missingData("No user id found.")
        }

        return (userId1, userId2)
    }
}
