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

import AzureCore
import Foundation

/// Result of the create thread operation.
public struct CreateThreadResult: Codable {
    // MARK: Properties

    /// Chat thread.
    public let thread: Thread?
    /// Errors encountered during the creation of the chat thread.
    public let errors: CreateChatThreadErrors?

    // MARK: Initializers

    public init(
        from createChatThreadResult: CreateChatThreadResult
    ) throws {
        if let chatThread = createChatThreadResult.chatThread {
            self.thread = try? Thread(from: chatThread)
        } else {
            self.thread = nil
        }
        self.errors = createChatThreadResult.errors
    }

    /// Initialize a `ChatThreadResult` structure.
    /// - Parameters:
    ///   - thread: Chat thread.
    ///   - errors: Errors encountered during the creation of the chat thread.
    public init(
        thread: Thread? = nil,
        errors: CreateChatThreadErrors? = nil
    ) {
        self.thread = thread
        self.errors = errors
    }
}
