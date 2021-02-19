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
    ) throws {
        self.id = chatThread.id
        self.topic = chatThread.topic
        self.createdOn = chatThread.createdOn

        // Deserialize the identifier to CommunicationUserIdentifier
        let identifier = try IdentifierSerializer.deserialize(identifier: chatThread.createdByCommunicationIdentifier)

        if let createdBy = identifier as? CommunicationUserIdentifier {
            self.createdBy = createdBy
        } else {
            throw AzureError.client("Identifier for Thread is not a CommunicationUserIdentifier.")
        }

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

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case id
        case topic
        case createdOn
        case createdBy = "createdByCommunicationIdentifier"
        case deletedOn
    }

    /// Initialize a `Thread` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.topic = try container.decode(String.self, forKey: .topic)
        self.createdOn = try container.decode(Iso8601Date.self, forKey: .createdOn)

        // Decode CommunicationIdentifierModel to CommunicationUserIdentifier
        let identifierModel = try container.decode(CommunicationIdentifierModel.self, forKey: .createdBy)
        let identifier = try IdentifierSerializer.deserialize(identifier: identifierModel)

        if let createdBy = identifier as? CommunicationUserIdentifier {
            self.createdBy = createdBy
        } else {
            throw AzureError.client("Identifier for Thread is not a CommunicationUserIdentifier.")
        }

        self.deletedOn = try? container.decode(Iso8601Date.self, forKey: .deletedOn)
    }

    /// Encode a `Thread` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(topic, forKey: .topic)
        try container.encode(createdOn, forKey: .createdOn)

        // Encode CommunicationUserIdentifier to CommunicationIdentifierModel
        let identifierModel = try IdentifierSerializer.serialize(identifier: createdBy)
        try container.encode(identifierModel, forKey: .createdBy)

        if deletedOn != nil { try? container.encode(deletedOn, forKey: .deletedOn) }
    }
}
