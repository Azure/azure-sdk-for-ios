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

class TestConfig {
    public static let mode: String = "playback"
    public static let user1: String = "id:1"
    public static let user2: String = "id:2"
    public static let timeout: TimeInterval = 10.0

    /// Creates and returns a ChatClient
    public static func getChatClient() throws -> ChatClient {
        let endpoint = "https://endpoint"
        let token = generateToken()
        let credential = try CommunicationTokenCredential(token: token)
        let options = AzureCommunicationChatClientOptions()

        return try ChatClient(endpoint: endpoint, credential: credential, withOptions: options)
    }
}

func generateToken() -> String {
    let fakeValue = "{\"iss\":\"ACS\",\"iat\": 1608152725,\"exp\": 1739688725,\"aud\": \"\",\"sub\": \"\"}"
        .base64EncodedString()
    return "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9." + fakeValue + ".EMS0ExXqRuobm34WKJE8mAfZ7KppU5kEHl0OFdyree8"
}
