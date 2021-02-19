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

/// A participant of the chat thread.
public struct Participant: Codable {
    // MARK: Properties

    /// The CommunicationUserIdentifier for the participant.
    public let user: CommunicationUserIdentifier
    /// Display name for the participant.
    public let displayName: String?
    /// Time from which the chat history is shared with the participant. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let shareHistoryTime: Iso8601Date?

    // MARK: Initializers

    /// Initialize a `Participant` structure from a ChatParticipant.
    /// - Parameters:
    ///   - chatParticipant: The ChatParticipant to initialize from.
    public init(
        from chatParticipant: ChatParticipant
    ) throws {
        // Deserialize the identifier to CommunicationUserIdentifier
        let identifier = try IdentifierSerializer.deserialize(identifier: chatParticipant.communicationIdentifier)

        if let user = identifier as? CommunicationUserIdentifier {
            self.user = user
        } else {
            throw AzureError.client("Identifier for Participant is not a CommunicationUserIdentifier.")
        }

        self.displayName = chatParticipant.displayName
        self.shareHistoryTime = chatParticipant.shareHistoryTime
    }

    /// Initialize a `Participant` structure.
    /// - Parameters:
    ///   - id: The id of the participant.
    ///   - displayName: Display name for the participant.
    ///   - shareHistoryTime: Time from which the chat history is shared with the participant. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public init(
        id: String,
        displayName: String? = nil,
        shareHistoryTime: Iso8601Date? = nil
    ) {
        self.user = CommunicationUserIdentifier(identifier: id)
        self.displayName = displayName
        self.shareHistoryTime = shareHistoryTime
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case user = "communicationIdentifier"
        case displayName
        case shareHistoryTime
    }

    /// Initialize a `Participant` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode CommunicationIdentifierModel to CommunicationUserIdentifier
        let identifierModel = try container.decode(CommunicationIdentifierModel.self, forKey: .user)
        self.user = try IdentifierSerializer.deserialize(identifier: identifierModel) as! CommunicationUserIdentifier

        self.displayName = try? container.decode(String.self, forKey: .displayName)
        self.shareHistoryTime = try? container.decode(Iso8601Date.self, forKey: .shareHistoryTime)
    }

    /// Encode a `Participant` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encode CommunicationUserIdentifier to CommunicationIdentifierModel
        let identifierModel = try IdentifierSerializer.serialize(identifier: user)
        try container.encode(identifierModel, forKey: .user)

        if displayName != nil { try? container.encode(displayName, forKey: .displayName) }
        if shareHistoryTime != nil { try? container.encode(shareHistoryTime, forKey: .shareHistoryTime) }
    }
}
