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
import AzureCore
import Foundation

/// Chat thread.
public struct Thread: Codable {
    // MARK: Properties

    /// Thread id.
    public let id: String
    /// Thread topic.
    public let topic: String
    /// The timestamp when the thread was created. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let createdOn: Iso8601Date
    /// CommunicationUserIdentifier of the thread owner.
    public let createdBy: CommunicationUserIdentifier
    /// The timestamp when the thread was deleted. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let deletedOn: Iso8601Date?

    // MARK: Initializers

    /// Initialize a `ChatThread` structure from a ChatThread.
    /// - Parameters:
    ///   - chatThread: The ChatThread to initialize from.
    public init(
        from chatThread: ChatThread
    ) {
        self.id = chatThread.id
        self.topic = chatThread.topic
        self.createdOn = chatThread.createdOn
        self.createdBy = CommunicationUserIdentifier(identifier: chatThread.createdBy)
        self.deletedOn = chatThread.deletedOn
    }

    /// Initialize a `ChatThread` structure.
    /// - Parameters:
    ///   - id: Thread id.
    ///   - topic: Thread topic.
    ///   - createdOn: The timestamp when the thread was created. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    ///   - createdBy: Id of the thread owner.
    ///   - deletedOn: The timestamp when the thread was deleted. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public init(
        id: String,
        topic: String,
        createdOn: Iso8601Date,
        createdBy: String,
        deletedOn: Iso8601Date? = nil
    ) {
        self.id = id
        self.topic = topic
        self.createdOn = createdOn
        self.createdBy = CommunicationUserIdentifier(identifier: createdBy)
        self.deletedOn = deletedOn
    }
}
