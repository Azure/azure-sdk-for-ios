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

import Foundation
import AzureCore

/// PushNotificationChatEventType representing the different events for push notifications
public enum PushNotificationChatEventType: String {
    case chatMessageReceived
    case chatMessageEdited
    case chatMessageDeleted
    case chatThreadCreated
    case chatThreadPropertiesUpdated
    case chatThreadDeleted
    case participantsAdded
    case participantsRemoved

    init(forCode code: Int) throws {
        switch code {
        case 200:
            self = .chatMessageReceived
        case 247:
            self = .chatMessageEdited
        case 248:
            self = .chatMessageDeleted
        case 257:
            self = .chatThreadCreated
        case 258:
            self = .chatThreadPropertiesUpdated
        case 259:
            self = .chatThreadDeleted
        case 260:
            self = .participantsAdded
        case 261:
            self = .participantsRemoved
        default:
            throw AzureError.client("Event id: \(code) is unsupported")
        }
    }
}
